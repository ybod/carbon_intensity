defmodule CarbonIntensity.CarbonIntensityMeasurements do
  @moduledoc """
  Carbon intensity measurements context
  """

  import Ecto.Query, only: [from: 2]

  alias CarbonIntensity.CarbonIntensityMeasurement
  alias CarbonIntensity.Repo

  def create(from, actual_intensity) do
    Repo.insert(get_changeset(from, actual_intensity))
  end

  def create!(from, actual_intensity) do
    {:ok, measurement} = create(from, actual_intensity)
    measurement
  end

  def get(%DateTime{} = from) do
    Repo.get_by(CarbonIntensityMeasurement, from: from)
  end

  def upsert(from, actual_intensity) do
    Repo.insert(get_changeset(from, actual_intensity),
      conflict_target: :from,
      on_conflict: {:replace_all_except, [:from]}
    )
  end

  def get_latest() do
    from(measurement in CarbonIntensityMeasurement, order_by: [desc: measurement.from], limit: 1)
    |> Repo.one()
  end

  def all_by_period(%DateTime{} = period_start, %DateTime{} = period_end) do
    from(measurement in CarbonIntensityMeasurement,
      where: measurement.from >= ^period_start and measurement.from <= ^period_end,
      order_by: measurement.from
    )
    |> Repo.all()
  end

  # Helpers

  defp get_changeset(from, actual_intensity) do
    CarbonIntensityMeasurement.changeset(%CarbonIntensityMeasurement{}, %{
      from: from,
      actual_intensity: actual_intensity
    })
  end
end
