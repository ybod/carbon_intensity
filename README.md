# CarbonIntensity

UK National Grid CO2 emissions related to electricity production

Applications requires [TimescaleDB](https://www.timescale.com/) to run.

Application will use [Official Carbon Intensity API for Great Britain](https://carbon-intensity.github.io/api-definitions/#carbon-intensity-api-v2-0-0) to get Carbon Intensity data for te last 24hrs (UTC+0)

Data will be updated every 5 min. This interval can be changed with `update_interval` parameter `config/config.exs`

## Installation

- start local TimescaleDB instance with `docker compose up -d`
- dependendices and database setup `mix setup`
- run app locally in dev mode `mix run --no-halt`

## Testing

- start local TimescaleDB instance with `docker compose up`
- `mix test`

One test against the real API will be scipped. You can comment skip tag to run this test.


