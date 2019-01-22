defmodule CoreWeb.API.OAuthView do
    use CoreWeb.Web, :view
    @attributes ~W(cid name url image redirect trusted)

    def render("list.json", %{data: clients}) when is_list(clients) do
        for client <- clients do
            render("list.json", data: client)
        end
    end

    def render("list.json", %{data: client}) do
        client
        |> Map.take([:cid, :name, :url, :image, :redirect, :trusted])
    end
end