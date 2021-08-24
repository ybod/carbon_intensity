defmodule CarbonIntensity.HttpClient do
  @moduledoc """
  HTTP Client module implementation with Finch
  """

  @behaviour CarbonIntensity.HttpClientBehaviour

  @finch_name CarbonIntensity.Finch

  @impl CarbonIntensity.HttpClientBehaviour
  def get_json(url, headers \\ []) when is_binary(url) and is_list(headers) do
    req_headers = [
      {"Accept", "application/json"},
      {"Accept-Charset", "UTF-8"},
      {"Accept-Encoding", "gzip, deflate"} | headers
    ]

    Finch.build(:get, url, req_headers)
    |> Finch.request(@finch_name)
    |> process_json_resp()
  end

  # Helpers

  defp process_json_resp({:error, error}), do: {:error, {:http_client, error}}

  defp process_json_resp({:ok, %{body: body, headers: headers, status: status}}) when status in 200..299 do
    body = maybe_decompress_body(body, get_content_encoding(headers))

    if content_type_json?(headers) do
      case Jason.decode(body) do
        {:ok, res} -> {:ok, res}
        {:error, error} -> {:error, {:http_client, error, body}}
      end
    else
      {:ok, body}
    end
  end

  defp process_json_resp({:ok, %{body: body, headers: headers, status: status}}) do
    body = maybe_decompress_body(body, get_content_encoding(headers))

    if content_type_json?(headers) do
      case Jason.decode(body) do
        {:ok, decoded_body} -> {:error, {:http_client, status, decoded_body}}
        {:error, _} -> {:error, {:http_client, status, body}}
      end
    else
      {:error, {:http_client, status, body}}
    end
  end

  defp get_content_encoding(headers) when is_list(headers) do
    case Enum.find_value(headers, fn {k, v} -> if k == "content-encoding", do: v end) do
      "gzip" -> :gzip
      "deflate" -> :deflate
      _ -> :unknown
    end
  end

  defp maybe_decompress_body(<<0x1F, 0x8B, 0x08, _::binary>> = body, :gzip), do: :zlib.gunzip(body)
  defp maybe_decompress_body(body, :deflate), do: :zlib.unzip(body)
  defp maybe_decompress_body(body, _content_encoding), do: body

  defp content_type_json?(headers) when is_list(headers) do
    case Enum.find(headers, fn {h, _v} -> h == "content-type" end) do
      nil -> false
      {_h, v} -> String.starts_with?(v, "application/json")
    end
  end
end
