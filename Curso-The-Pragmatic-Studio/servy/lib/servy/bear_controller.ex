defmodule Servy.BearController do
  alias Servy.Wildthings
  alias Servy.Bear

  def index(request) do
    items =
      Wildthings.list_bears()
      |> Enum.filter(&Bear.is_grizzly(&1))
      |> Enum.sort(fn(b1, b2) -> Bear.order_asc_by_name(b1, b2) end)
      |> Enum.map(fn(b) -> bear_item(b) end)

      %{ request | status: 200, resp_body: "<ul>#{items}</ul>"}
  end

  def show(request, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{ request | status: 200, resp_body: "<h1>Bear #{bear.id}: #{bear.name} </h1>"}
  end

  def create(request, %{"name" => name, "type" => type} = params) do
    %{ request | status: 201,
                 resp_body: "Created a #{type} bear named #{name}!"}
  end

  defp bear_item(bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end
end
