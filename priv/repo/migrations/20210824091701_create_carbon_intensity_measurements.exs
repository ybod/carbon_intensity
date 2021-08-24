defmodule CarbonIntensity.Repo.Migrations.CreateCarbonIntensityMeasurements do
  use Ecto.Migration

  def change do
    create table(:carbon_intensity_measurements, primary_key: false) do
      add(:from, :utc_datetime, null: false)
      add(:actual_intensity, :integer, null: false)
    end

    execute("SELECT create_hypertable('carbon_intensity_measurements', 'from')")
  end
end
