defmodule Servy.Handler do

  @moduledoc "usado para documentar os modulos"

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  defp route(%{method: "GET", path: "/about"} = request) do
    file =
      @pages_path
      |> Path.join("about.html")

    case File.read(file) do
      {:ok, content} ->
        %{request | status: 200, resp_body: content}

      {:error, :enoent} ->
        %{request | status: 404, resp_body: "File not found!"}

      {:error, reason} ->
        %{request | status: 500, resp_body: "File error #{reason}"}
    end
  end

  defp route(%{method: "GET", path: "/wildthings"} = parsed_request) do
    %{ parsed_request | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  defp route(%{method: "GET", path: "/bears"} = parsed_request) do
    %{ parsed_request | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  defp route(%{method: "GET", path: "/bears/" <> id} = parsed_request) do
    %{ parsed_request | status: 200, resp_body: "Bear #{id}"}
  end

  defp route(%{ path: path } = parsed_request) do
    %{ parsed_request | status: 404, resp_body: "No #{path} here!"}
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      404 => "Not Found"
    }[code]
  end

  defp format_response(response) do
    """
    HTTP/1.1 #{response.status} #{status_reason(response.status)}
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
