defmodule CoreWeb.UserManager.ErrorHandler do
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = to_string(type)

    case body do
      "unauthenticated" -> 
        conn 
          |> put_session(:auth_redirect, 
            "http://" <> conn.host 
            <> ":" <> Integer.to_string(conn.port)
            <> conn.request_path <> "?" <> conn.query_string)
        |> Phoenix.Controller.redirect(to: "/auth/nopass")
      _ -> conn
      |> put_resp_content_type("text/plain")
      |> send_resp(401, body)
    end
  end
end
