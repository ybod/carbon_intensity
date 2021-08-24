defmodule CarbonIntensity.HttpClientBehaviour do
  @moduledoc """
  Behaviour for HTTP Client module
  """

  @type url :: String.t()
  @type headers :: list()
  @type body :: String.t()
  @type json_body :: map()

  @callback get_json(url) :: {:ok, term} | {:error, term}
  @callback get_json(url, headers | []) :: {:ok, term} | {:error, term}
end
