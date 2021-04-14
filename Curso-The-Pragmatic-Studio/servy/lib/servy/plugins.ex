defmodule Servy.Plugins do
   @doc "usado para documentar as funcoes"

   alias Servy.Request

   def track(%Request{status: 404, path: path} = request) do
    IO.puts "Warning: #{path} is on the loose!"
    request
  end

  def track(%Request{} = request), do: request

  def rewrite_path(%Request{path: "/wildlife"} = request) do
    %{request | path: "/wildthings"}
  end

  def rewrite_path(request), do: request

  def log(%Request{} = request) do
    IO.inspect request
  end
end
