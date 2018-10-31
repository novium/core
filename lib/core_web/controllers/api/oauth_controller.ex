defmodule CoreWeb.API.OAuthController do
    use CoreWeb.Web, :controller

    alias Core.Repo
    alias Core.OAuth.Client

    def list(conn, _params) do
        clients = Repo.all(Client)
        conn 
        |> json(clients)
    end

    def create(conn, %{"name" => name,
                        "url" => url,
                        "redirect" => redirect} = _params) do
        data = %{
            cid: Ecto.UUID.generate,
            name: name,
            url: url,
            redirect: redirect,
            secret: Ecto.UUID.generate,
            trusted: true # TODO
        }

        result = Client.changeset(
            %Client{},
            data) |> Repo.insert

            case result do
                {:ok, client} -> json(conn, %{ "client" => data })
                _ -> json(conn, %{"error" => "something went wrong"})
            end
    end

    def create(conn, _params) do
        json(conn, %{"error" => "fields missing"})
    end
end