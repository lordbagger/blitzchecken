defmodule Blitzchecken do
  def main(args) when is_binary(args) do
    args
    |> parse_args
    |> Enum.map(&Task.async(Blitzchecken.Worker, :check_url, [&1]))
    |> Enum.map(&Task.await(&1))
    |> Enum.each(&IO.puts(&1))
  end

  defp parse_args(args) do
    args |> String.split()
  end
end
