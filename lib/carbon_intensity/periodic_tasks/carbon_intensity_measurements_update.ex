defmodule CarbonIntensity.PeriodicTask.CarbonIntensityMeasurementsUpdate do
  @moduledoc """
  Get Carbon Intensity data 24hrs in the past of a current datetime

  https://carbon-intensity.github.io/api-definitions/#get-intensity-from-pt24h
  """

  use Clerk.PeriodicTask

  require Logger

  alias CarbonIntensity.CarbonIntensityMeasurements

  @impl true
  def init(params) do
    http_client = Map.get(params, :http_client, ForzaChallenge.HttpClient)

    {:ok, %{http_client: http_client}}
  end

  @impl true
  def execute(%{http_client: http_client} = state) do
    update_time = DateTime.truncate(DateTime.utc_now(), :second)

    with {:ok, resp} <- http_client.get_json(get_url(update_time)),
         {:ok, measurements_data} <- get_measurements_data(resp),
         {:ok, measurements} <- parse_measurements_data(measurements_data, []) do
      count = upsert_all_measurements(measurements)
      Logger.info("#{count} measurements updated at #{datetime_to_iso!(update_time)}")
    else
      {:error, error} ->
        Logger.error("measurements update at #{datetime_to_iso!(update_time)} failed - #{inspect(error)}")
    end

    {:ok, state}
  end

  defp get_url(%DateTime{} = from) do
    "https://api.carbonintensity.org.uk/intensity/#{datetime_to_iso!(from)}/pt24h"
  end

  defp datetime_to_iso!(datetime), do: DateTime.to_iso8601(datetime)

  defp get_measurements_data(%{"data" => data}) when is_list(data), do: {:ok, data}
  defp get_measurements_data(other), do: {:error, {:invalid_response, other}}

  defp parse_measurements_data([], results) do
    non_empty_measurements = Enum.reject(results, &is_nil(&1.actual_intensity))

    {:ok, non_empty_measurements}
  end

  defp parse_measurements_data([item | rest], results) do
    case parse_measurement_data(item) do
      {:ok, measurement_params} ->
        parse_measurements_data(rest, [measurement_params | results])

      {:error, reason} ->
        Logger.warn("Invalid measurement (skip): #{inspect(item)} - #{inspect(reason)}")
        parse_measurements_data(rest, results)
    end
  end

  defp parse_measurement_data(%{"from" => from, "intensity" => %{"actual" => actual}}) do
    with {:ok, from} <- parse_datetime(from),
         {:ok, actual_intensity} <- maybe_positive_integer_or_nil(actual) do
      {:ok, %{from: from, actual_intensity: actual_intensity}}
    end
  end

  defp parse_measurement_data(_other), do: {:error, :invalid_map}

  defp parse_datetime(nil), do: {:error, {:invalid_time, nil}}

  defp parse_datetime(datetime_str) when is_binary(datetime_str) do
    datetime_str = String.replace_trailing(datetime_str, "Z", ":00Z")

    case DateTime.from_iso8601(datetime_str) do
      {:ok, datetime, 0} -> {:ok, datetime}
      {:error, error} -> {:error, {:invalid_from, error}}
    end
  end

  defp maybe_positive_integer_or_nil(nil), do: {:ok, nil}

  defp maybe_positive_integer_or_nil(maybe_int) do
    if is_integer(maybe_int) and maybe_int > 0, do: {:ok, maybe_int}, else: {:error, {:invalid_value, maybe_int}}
  end

  defp upsert_all_measurements(measurements) when is_list(measurements) do
    Enum.reduce(measurements, 0, fn %{actual_intensity: actual_intensity, from: from}, count ->
      case CarbonIntensityMeasurements.upsert(from, actual_intensity) do
        {:ok, _} ->
          count + 1

        {:error, %{errors: errors}} ->
          Logger.error("Error upserting measurement from #{inspect(from)} - #{inspect(errors)}")
          count
      end
    end)
  end
end
