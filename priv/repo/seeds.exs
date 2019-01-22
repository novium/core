# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Core.Repo.insert!(%Core.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

{:ok, cid} = Ecto.UUID.cast("a1ed474f-f01d-4886-8d7b-b3ee63534608")

Core.Repo.insert!(%Core.OAuth.Client{
    cid: cid,
    name: "[DEV_SEED] coreweb client",
    url: "http://localhost:8080",
    redirect: "http://localhost:8080/",
    image: "http://placehold.it/200x200",
    secret: Ecto.UUID.generate,
    trusted: true
});