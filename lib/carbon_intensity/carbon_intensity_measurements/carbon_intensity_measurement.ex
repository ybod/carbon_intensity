defmodule CarbonIntensity.CarbonIntensityMeasurement do
  @moduledoc """
  Carbon intensity measurement schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  schema "carbon_intensity_measurements" do
    field(:from, :utc_datetime)
    field(:actual_intensity, :integer)
  end

  def changeset(carbon_intensity_measurements, params \\ %{}) do
    carbon_intensity_measurements
    |> cast(params, [:from, :actual_intensity])
    |> validate_required([:from, :actual_intensity])
    |> validate_number(:actual_intensity, greater_than: 0)
  end
end
