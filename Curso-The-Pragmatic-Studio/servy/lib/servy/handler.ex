defmodule Servy.Handler do

  @moduledoc "usado para documentar os modulos"

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  alias Servy.Request
  alias Servy.BearController

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  defp route(%Request{method: "GET", path: "/wildthings"} = parsed_request) do
    %{ parsed_request | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  defp route(%Request{method: "GET", path: "/bears"} = parsed_request) do
    BearController.index(parsed_request)
  end

  defp route(%Request{method: "POST", path: "/bears"} = parsed_request) do
    BearController.create(parsed_request, parsed_request.params)
  end

  defp route(%Request{method: "GET", path: "/bears/" <> id} = parsed_request) do
    params = Map.put(parsed_request.params, "id", id)
    BearController.show(parsed_request, params)
  end

  defp route(%Request{method: "GET", path: "/about"} = request) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(request)
  end

  defp route(%Request{ path: path } = parsed_request) do
    %{ parsed_request | status: 404, resp_body: "No #{path} here!"}
  end

  defp handle_file({:ok, content}, request) do
    %{request | status: 200, resp_body: content}
  end

  defp handle_file({:error, :enoent}, request) do
    %{request | status: 404, resp_body: "File not found!"}
  end

  defp handle_file({:error, reason}, request) do
    %{request | status: 500, resp_body: "File error #{reason}"}
  end

  defp format_response(%Request{} = response) do
    """
    HTTP/1.1 #{Request.full_status(response)}
    Content-Type: text/html
    Content-Length: #{String.length(response.resp_body)}

    #{response.resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)


IO.puts response

request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response

request = """
GET /bacon HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)

IO.puts response


request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response = Servy.Handler.handle(request)

IO.puts response
