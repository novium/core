defmodule Core.OAclientTest do
  use Core.ModelCase

  alias Core.OAclient

  @valid_attrs %{cid: "some content", name: "some content", secret: "some content", url: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = OAclient.changeset(%OAclient{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = OAclient.changeset(%OAclient{}, @invalid_attrs)
    refute changeset.valid?
  end
end
