# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :carbon_intensity,
  ecto_repos: [CarbonIntensity.Repo],
  env: config_env(),
  update_interval: :timer.minutes(5)

# Configures Elixir's Logger
config :logger, :console, format: "$time $metadata[$level] $message\n"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
