defmodule CoreWeb.Plugs.OAuth do
    import Plug.Conn
    
    alias Core.User
    alias Core.OAuth.Authorization

    def init(default) do
        default
    end

    def call(%Plug.Conn{params: %{"access_token" => token}} = conn, opts) do
        case token do
            "" -> error(conn, opts)
            token -> ok(conn, opts, token)
        end
    end

    def call(%Plug.Conn{req_headers: headers} = conn, opts) do
        case to_string(for {"authorization", value} <- headers, do: value) do
            "" -> error(conn, opts)
            bearer -> ok(conn, opts, String.split(bearer) |> List.last)
        end
    end

    defp ok(conn, _opts, token) do
        conn
    end

    defp error(conn, _opts) do
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(200, "Not authorized")
        |> halt
    end
end