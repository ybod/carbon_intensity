defmodule CarbonIntensity.PeriodicTask.CarbonIntensityMeasurementsUpdateTest do
  use CarbonIntensity.DataCase, async: true

  import Mox

  alias CarbonIntensity.CarbonIntensityMeasurements
  alias CarbonIntensity.PeriodicTask.CarbonIntensityMeasurementsUpdate

  test "execute can parse valid response and upsert all data" do
    CarbonIntensity.MockHttpClient
    |> expect(:get_json, 1, fn url ->
      assert url =~ "https://api.carbonintensity.org.uk/intensity/"
      {:ok, load_json_fixtures!("valid_response.json")}
    end)

    {:ok, _} = CarbonIntensityMeasurementsUpdate.execute(%{http_client: CarbonIntensity.MockHttpClient})

    non_nil_fixtures =
      load_json_fixtures!("valid_response.json")
      |> Map.fetch!("data")
      |> Enum.reject(&(get_in(&1, ["intensity", "actual"]) == nil))

    all_db_measurements = CarbonIntensityMeasurements.all()
    assert length(all_db_measurements) == length(non_nil_fixtures)

    first_fixure = List.first(non_nil_fixtures)
    fist_db_measurement = List.first(all_db_measurements)

    assert fist_db_measurement.from == parse_fixture_datetime!(first_fixure["from"])
    assert fist_db_measurement.actual_intensity == get_in(first_fixure, ["intensity", "actual"])

    last_fixure = List.last(non_nil_fixtures)
    last_db_measurement = List.last(all_db_measurements)

    assert last_db_measurement.from == parse_fixture_datetime!(last_fixure["from"])
    assert last_db_measurement.actual_intensity == get_in(last_fixure, ["intensity", "actual"])
  end

  test "can process API error response" do
    CarbonIntensity.MockHttpClient
    |> expect(:get_json, 1, fn _url ->
      {:error,
       {:http_client, 400,
        %{
          "error" => %{
            "code" => "400 Bad Request",
            "message" =>
              "Please enter a valid datetime in ISO8601 format YYYY-MM-DDThh:mmZ e.g. /intensity/2017-08-25T15:30Z/pt24h"
          }
        }}}
    end)

    {:ok, _} = CarbonIntensityMeasurementsUpdate.execute(%{http_client: CarbonIntensity.MockHttpClient})
  end

  test "can process invalid response format" do
    json_fixtures = [
      load_json_fixtures!("invalid_response_datetime.json"),
      load_json_fixtures!("invalid_response_value.json")
    ]

    for json_fixt <- json_fixtures do
      CarbonIntensity.MockHttpClient
      |> expect(:get_json, 1, fn _url -> {:ok, json_fixt} end)

      {:ok, _} = CarbonIntensityMeasurementsUpdate.execute(%{http_client: CarbonIntensity.MockHttpClient})

      assert [
               %CarbonIntensity.CarbonIntensityMeasurement{
                 actual_intensity: 195,
                 from: ~U[2021-08-23 23:00:00Z]
               }
             ] = CarbonIntensityMeasurements.all()
    end
  end

  @tag :skip
  test "test agains the real API" do
    {:ok, _} = CarbonIntensityMeasurementsUpdate.execute(%{http_client: CarbonIntensity.HttpClient})

    refute [] == CarbonIntensityMeasurements.all()
  end

  # Helpers

  defp load_json_fixtures!(file_name) do
    Path.join(__DIR__, file_name)
    |> File.read!()
    |> Jason.decode!()
  end

  defp parse_fixture_datetime!(datetime_str) do
    {:ok, datetime, 0} =
      datetime_str
      |> String.replace_trailing("Z", ":00Z")
      |> DateTime.from_iso8601()

    datetime
  end
end
