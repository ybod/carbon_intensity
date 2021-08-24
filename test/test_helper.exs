ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(CarbonIntensity.Repo, :manual)

# Mox
Mox.defmock(CarbonIntensity.MockHttpClient, for: CarbonIntensity.HttpClientBehaviour)
