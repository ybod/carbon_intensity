defmodule CarbonIntensity.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CarbonIntensity.Repo,
      {Finch, name: CarbonIntensity.Finch},
      # Periodic tasks
      {Clerk, carbon_intensity_measurements_update_params()}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CarbonIntensity.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def env(), do: Application.fetch_env!(:carbon_intensity, :env)

  defp carbon_intensity_measurements_update_params() do
    %{
      enabled: env() != :test,
      execution_interval: Application.fetch_env!(:carbon_intensity, :update_interval),
      execute_on_start: true,
      task_module: CarbonIntensity.PeriodicTask.CarbonIntensityMeasurementsUpdate,
      init_args: %{http_client: CarbonIntensity.HttpClient}
    }
  end
end
