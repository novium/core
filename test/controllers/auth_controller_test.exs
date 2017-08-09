defmodule Core.AuthControllerTest do
  use Core.ConnCase

  alias Core.Auth
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, auth_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing auth"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, auth_path(conn, :new)
    assert html_response(conn, 200) =~ "New auth"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, auth_path(conn, :create), auth: @valid_attrs
    assert redirected_to(conn) == auth_path(conn, :index)
    assert Repo.get_by(Auth, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, auth_path(conn, :create), auth: @invalid_attrs
    assert html_response(conn, 200) =~ "New auth"
  end

  test "shows chosen resource", %{conn: conn} do
    auth = Repo.insert! %Auth{}
    conn = get conn, auth_path(conn, :show, auth)
    assert html_response(conn, 200) =~ "Show auth"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, auth_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    auth = Repo.insert! %Auth{}
    conn = get conn, auth_path(conn, :edit, auth)
    assert html_response(conn, 200) =~ "Edit auth"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    auth = Repo.insert! %Auth{}
    conn = put conn, auth_path(conn, :update, auth), auth: @valid_attrs
    assert redirected_to(conn) == auth_path(conn, :show, auth)
    assert Repo.get_by(Auth, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    auth = Repo.insert! %Auth{}
    conn = put conn, auth_path(conn, :update, auth), auth: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit auth"
  end

  test "deletes chosen resource", %{conn: conn} do
    auth = Repo.insert! %Auth{}
    conn = delete conn, auth_path(conn, :delete, auth)
    assert redirected_to(conn) == auth_path(conn, :index)
    refute Repo.get(Auth, auth.id)
  end
end
