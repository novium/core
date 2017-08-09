defmodule Core.AuthTest do
  use Core.ModelCase

  alias Core.Auth

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Auth.changeset(%Auth{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Auth.changeset(%Auth{}, @invalid_attrs)
    refute changeset.valid?
  end
end
