defmodule CarbonIntensity.CarbonIntensityMeasurementsTest do
  use CarbonIntensity.DataCase, async: true

  alias CarbonIntensity.CarbonIntensityMeasurement
  alias CarbonIntensity.CarbonIntensityMeasurements

  test "create creates measurement" do
    from_datetime = DateTime.utc_now() |> DateTime.truncate(:second)
    actual_val = :rand.uniform(1000)

    {:ok, measurement} = CarbonIntensityMeasurements.create(from_datetime, actual_val)

    assert %CarbonIntensityMeasurement{from: ^from_datetime, actual_intensity: ^actual_val} = measurement
  end

  test "get returns measurement from date and time" do
    from_datetime = DateTime.utc_now() |> DateTime.truncate(:second)
    actual_val = :rand.uniform(1000)

    CarbonIntensityMeasurements.create!(from_datetime, actual_val)

    assert %CarbonIntensityMeasurement{from: ^from_datetime, actual_intensity: ^actual_val} =
             CarbonIntensityMeasurements.get(from_datetime)

    assert nil == CarbonIntensityMeasurements.get(DateTime.add(from_datetime, _mins_5 = -300))
  end

  test "upsert upsert measurement" do
    {:ok, _measurement} = CarbonIntensityMeasurements.upsert(~U[2021-08-24 13:00:00Z], 100)
    assert %{actual_intensity: 100} = CarbonIntensityMeasurements.get(~U[2021-08-24 13:00:00Z])

    {:ok, _measurement} = CarbonIntensityMeasurements.upsert(~U[2021-08-24 13:00:00Z], 500)
    assert %{actual_intensity: 500} = CarbonIntensityMeasurements.get(~U[2021-08-24 13:00:00Z])
  end

  test "get_latest returns latest measurement" do
    assert nil == CarbonIntensityMeasurements.get_latest()

    CarbonIntensityMeasurements.create!(~U[2021-08-24 13:00:00Z], 100)
    CarbonIntensityMeasurements.create!(~U[2021-08-24 14:00:00Z], 300)

    assert %{actual_intensity: 300, from: ~U[2021-08-24 14:00:00Z]} = CarbonIntensityMeasurements.get_latest()
  end

  test "all_by_period returns list of measurements from given period" do
    CarbonIntensityMeasurements.create!(~U[2021-08-24 13:00:00Z], 100)
    CarbonIntensityMeasurements.create!(~U[2021-08-24 13:30:00Z], 200)
    CarbonIntensityMeasurements.create!(~U[2021-08-24 14:00:00Z], 300)
    CarbonIntensityMeasurements.create!(~U[2021-08-24 14:30:00Z], 400)

    [mes_1, mes_2] = CarbonIntensityMeasurements.all_by_period(~U[2021-08-24 13:15:00Z], ~U[2021-08-24 14:15:00Z])

    assert %{actual_intensity: 200, from: ~U[2021-08-24 13:30:00Z]} = mes_1
    assert %{actual_intensity: 300, from: ~U[2021-08-24 14:00:00Z]} = mes_2

    assert [] = CarbonIntensityMeasurements.all_by_period(~U[2021-08-24 15:00:00Z], ~U[2021-08-24 15:30:00Z])
  end

  test "all return list of all measurements" do
    CarbonIntensityMeasurements.create!(~U[2021-08-24 13:00:00Z], 100)
    CarbonIntensityMeasurements.create!(~U[2021-08-24 13:30:00Z], 200)
    CarbonIntensityMeasurements.create!(~U[2021-08-24 14:00:00Z], 300)

    assert [%{actual_intensity: 100}, %{actual_intensity: 200}, %{actual_intensity: 300}] =
             CarbonIntensityMeasurements.all()
  end
end
