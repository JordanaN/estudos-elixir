defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  defp track(%{status: 404, path: path} = request) do
    IO.puts "Warning: #{path} is on the loose!"
    request
  end

  defp track(request), do: request

  defp rewrite_path(%{path: "/wildlife"} = request) do
    %{request | path: "/wildthings"}
  end

  defp rewrite_path(request), do: request

  def log(request) do
    IO.inspect request
  end

  defp parse(request) do
    [method, path, _] =
    request
    |> String.split("\n") ## isso me retorna uma lista [blabla, blulblu, bleble]
    |> List.first
    |> String.split(" ") ## tbm retorna uma lista com [GET, /wildthings, HTTP/1.1 "]

    %{method: method, status: nil, path: path, resp_body: ""}
  end

  defp route(%{method: "GET", path: "/about"} = request) do
    file =
      Path.expand("../../pages", __DIR__)
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
