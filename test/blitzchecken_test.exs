defmodule BlitzcheckenTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Mock

  test "given an input argument, prints the correct output in the console" do
    args = "https://www.ironmaiden.com  http://www.judaspriest.de not-a-url.com"

    expected_output = """
    GET https://www.ironmaiden.com -> 1.0 ms 200
    GET http://www.judaspriest.de -> 2.0 ms nxdomain
    IGNORED not-a-url.com
    """

    with_mock(HTTPoison, [
      get: fn
        ("https://www.ironmaiden.com") -> {:ok, %HTTPoison.Response{status_code: 200}}
        ("http://www.judaspriest.de") ->
          Process.sleep(1)
          {:error, %HTTPoison.Error{reason: :nxdomain}}
      end
    ]) do
      assert capture_io(fn -> Blitzchecken.main(args) end) == expected_output
    end
  end
end
