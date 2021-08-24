import Config

# Configure your database
config :carbon_intensity, CarbonIntensity.Repo,
  username: "postgres",
  password: "postgres",
  database: "carbon_intensity_dev",
  hostname: "localhost",
  port: 15432,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"
