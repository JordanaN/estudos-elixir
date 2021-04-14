defmodule Servy.Parser do
  def parse(request) do
    [method, path, _] =
    request
    |> String.split("\n") ## isso me retorna uma lista [blabla, blulblu, bleble]
    |> List.first
    |> String.split(" ") ## tbm retorna uma lista com [GET, /wildthings, HTTP/1.1 "]

    %{method: method, status: nil, path: path, resp_body: ""}
  end
end
