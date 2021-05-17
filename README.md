# Blitzchecken

Blitzchecken is a command-line program made in Elixir to check if a website is healthy and how long does it take to respond to a simple GET request.

## Prerequisites

You must of course have Elixir installed in your machine. 

If you don't, check: https://elixir-lang.org/install.html

## How to use it

In the root folder of this project you'll find two bash scripts:

- run.sh

- test.sh

To run the tests simply do:

```
$ ./test.sh
```

To run the program, simply run the 'run.sh' script with one or more url to be tested. 

For example:

````
$ ./run.sh http://google.com http://www.bing.com http://inactive-domain.blah htpp://not-a-web-url
````

The output should be something similar to this:

```
GET http://google.com -> 486.0 ms 301
GET http://www.bing.com -> 737.0 ms 200
GET http://inactive-domain.blah -> 123.0 ms nxdomain
IGNORED htpp://not-a-web-url
```

## How does it work?

The program consists basically of two modules: Blitzchecken and Blitzchecken.Worker

Let's have a look at Blitzchecken.Worker first:

````
# some helper functions were hidden

  def check_url(url) when is_binary(url) do
    case is_valid_url?(url) do
      true ->
        {timestamp, response} = Duration.measure(fn -> HTTPoison.get(url) end)
        handle_response({Duration.to_milliseconds(timestamp), url, response})

      false ->
        "IGNORED #{url}"
    end
  end
`````
This module does most of the logic: 

First it receives a url and checks, through a helper function, if it is valid or not. Assuming the URL is valid, a GET request is performed and the result is returned in the form of tuple containing the time it took to complete and the response of the request.

````

  defp handle_response({timestamp, url, {:ok, %HTTPoison.Response{status_code: status_code}}}) do
    output(timestamp, url) <> "#{status_code}"
  end

  defp handle_response({timestamp, url, {:error, %HTTPoison.Error{reason: reason}}}) do
    output(timestamp, url) <> "#{reason}"
  end

  defp output(timestamp, url) do
    "GET #{url} -> #{Float.ceil(timestamp, 0)} ms "
  end
````

The tuple is passed, alongside the URL to the handle_response function and pattern-matching is used to check what we received as a response and return the appropriate output.

Back to the Blitzchecken module: 

````
  def main(args) do
    args
    |> Enum.map(&Task.async(Blitzchecken.Worker, :check_url, [&1]))
    |> Enum.map(&Task.await(&1, :infinity))
    |> Enum.each(&IO.puts(&1))
  end

````

The 'main' function is entry point for the program. It receives a list of strings (each string being a URL) as arguments and will be passed to Blitzchecken.Worker to be executed asynchronously inside a Task behaviour. When a Task returns, the result is finally printed on the console.

## Libraries used:

HTTPoison - used to make http requests

Timex - used to measure the time a function takes to complete

Mock - library used to create mocks in tests 