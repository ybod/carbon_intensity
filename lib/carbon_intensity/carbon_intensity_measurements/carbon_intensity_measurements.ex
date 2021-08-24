defmodule CarbonIntensity.CarbonIntensityMeasurements do
  @moduledoc """
  Carbon intensity measurements context
  """

  import Ecto.Query, only: [from: 2]

  alias CarbonIntensity.CarbonIntensityMeasurement
  alias CarbonIntensity.Repo

  def create(from, actual_intensity) do
    CarbonIntensityMeasurement.changeset(%CarbonIntensityMeasurement{}, %{
      from: from,
      actual_intensity: actual_intensity
    })
    |> Repo.insert()
  end

  def create!(from, actual_intensity) do
    {:ok, measurement} = create(from, actual_intensity)
    measurement
  end

  def get(%DateTime{} = from) do
    Repo.get_by(CarbonIntensityMeasurement, from: from)
  end

  def all_by_period(%DateTime{} = period_start, %DateTime{} = period_end) do
    from(measurement in CarbonIntensityMeasurement,
      where: measurement.from >= ^period_start and measurement.from <= ^period_end,
      order_by: measurement.from
    )
    |> Repo.all()
  end
end
