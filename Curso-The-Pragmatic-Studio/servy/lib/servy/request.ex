defmodule Servy.Request do
  defstruct method: "",
            path: "",
            resp_body: "",
            params: "",
            status: nil

  def full_status(request) do
    "#{request.status} #{status_reason(request.status)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      404 => "Not Found",
      500 => "Internal server error"
    }[code]
  end
end
