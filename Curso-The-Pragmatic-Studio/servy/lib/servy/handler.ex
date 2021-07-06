defmodule Servy.Handler do

  @moduledoc "usado para documentar os modulos"

  @pages_path Path.expand("../../pages", __DIR__)

  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  alias Servy.Request
  alias Servy.BearController
  alias Servy.VideoCam

  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  defp route(%Request{ method: "GET", path: "/snapshots" } = parsed_request) do
    parent = self() # the request-handling process

    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-1")}) end)
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-2")}) end)
    spawn(fn -> send(parent, {:result, VideoCam.get_snapshot("cam-3")}) end)

    snapshot1 = receive do {:result, filename} -> filename end
    snapshot2 = receive do {:result, filename} -> filename end
    snapshot3 = receive do {:result, filename} -> filename end

    snapshots = [snapshot1, snapshot2, snapshot3]

    %{ parsed_request | status: 200, resp_body: inspect snapshots}
  end

  defp route(%Request{method: "GET", path: "/wildthings"} = parsed_request) do
    %{ parsed_request | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  defp route(%Request{method: "GET", path: "/api/bears"} = parsed_request) do
    Servy.Api.BearController.index(parsed_request)
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
    HTTP/1.1 #{Request.full_status(response)}\r
    Content-Type: #{response.resp_content_type}\r
    Content-Length: #{String.length(response.resp_body)}\r
    \r
    #{response.resp_body}
    """
  end
end
