defmodule WorkerTest do
  use ExUnit.Case
  import Mock

  test "ignores a malformed url" do
    url = "this-is-not-a-url"

    assert "IGNORED this-is-not-a-url" == Blitzchecken.Worker.check_url(url)
  end

  test "returns the expected output when a request is successful" do
    url = "https://www.ironmaiden.com"

    with_mock HTTPoison,
      get: fn url ->
        {:ok, %HTTPoison.Response{status_code: 200}}
      end do
      response = Blitzchecken.Worker.check_url(url)
      assert "GET https://www.ironmaiden.com -> 1.0 ms 200" == response
      assert called(HTTPoison.get(url))
    end
  end

  test "returns the expected output when an error occurs" do
    url = "https://www.merdallica.com"

    with_mock HTTPoison,
      get: fn url ->
        {:error, %HTTPoison.Error{reason: :nxdomain}}
      end do
      response = Blitzchecken.Worker.check_url(url)
      assert "GET https://www.merdallica.com -> 1.0 ms nxdomain" == response
      assert called(HTTPoison.get(url))
    end
  end
end
