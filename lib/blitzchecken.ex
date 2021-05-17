defmodule Blitzchecken do
  def main(args) do
    args
    |> Enum.map(&Task.async(Blitzchecken.Worker, :check_url, [&1]))
    |> Enum.map(&Task.await(&1, :infinity))
    |> Enum.each(&IO.puts(&1))
  end
end
