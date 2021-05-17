defmodule Blitzchecken.Worker do
  use Timex

  def check_url(url) when is_binary(url) do
    case is_valid_url?(url) do
      true ->
        {timestamp, response} = Duration.measure(fn -> HTTPoison.get(url) end)
        handle_response({Duration.to_milliseconds(timestamp), url, response})

      false ->
        "IGNORED #{url}"
    end
  end

  def check_url(something) do
    "IGNORED #{something}"
  end

  defp handle_response({timestamp, url, {:ok, %HTTPoison.Response{status_code: status_code}}}) do
    output(timestamp, url) <> "#{status_code}"
  end

  defp handle_response({timestamp, url, {:error, %HTTPoison.Error{reason: reason}}}) do
    output(timestamp, url) <> "#{reason}"
  end

  defp output(timestamp, url) do
    "GET #{url} -> #{Float.ceil(timestamp, 0)} ms "
  end

  defp is_valid_url?(url) when is_binary(url) do
    is_valid_url?(URI.parse(url))
  end

  defp is_valid_url?(%URI{scheme: nil}) do
    false
  end

  defp is_valid_url?(%URI{host: nil}) do
    false
  end

  defp is_valid_url?(%URI{scheme: "http", host: host}) do
    String.length(host) > 0
  end

  defp is_valid_url?(%URI{scheme: "https", host: host}) do
    String.length(host) > 0
  end

  defp is_valid_url?(%URI{scheme: _}) do
    false
  end
end
