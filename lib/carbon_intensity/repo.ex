defmodule CarbonIntensity.Repo do
  use Ecto.Repo,
    otp_app: :carbon_intensity,
    adapter: Ecto.Adapters.Postgres
end
