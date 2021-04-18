defmodule Servy.Parser do

  alias Servy.Request

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")
    [request_lines | header_lines] = String.split(top, "\n")
    [method, path, _] = String.split(request_lines, " ")

    headers = parse_headers(header_lines, %{})
    params = parse_params(headers["Content-Type"], params_string)

    %Request{
      method: method,
      path: path,
      params: params,
      headers: headers
    }
  end

  defp parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  defp parse_headers([], headers), do: headers

  defp parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  defp parse_params(_, _), do: %{}
end
