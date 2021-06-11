defmodule Servy.Request do
  defstruct method: "",
            path: "",
            resp_body: "",
            params: %{},
            headers: %{},
            resp_content_type: "text/html",
            status: nil

  def full_status(request) do
    "#{request.status} #{status_reason(request.status)}"
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end
end
