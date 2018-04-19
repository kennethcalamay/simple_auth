defmodule SimpleAuth.RegistrationControllerTest do
  use SimpleAuth.ConnCase

  alias SimpleAuth.User
  @valid_attrs %{username: "username", password: "password"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), user: @valid_attrs
    assert json_response(conn, 201)["data"]["username"]
    assert Repo.get_by(User, %{username: "username"})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not create resource when username already exists", %{conn: conn} do
    Repo.insert!(User.registration_changeset(%User{}, @valid_attrs))

    conn = post conn, registration_path(conn, :create), user: @valid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    old_user = Repo.insert! %User{username: "username"}
    conn = put conn, registration_path(conn, :update, old_user), user: %{username: "username", password: "another"}
    assert json_response(conn, 200)["data"]["password"] == "[FILTERED]"

    new_user = Repo.get_by(User, %{username: "username"})
    refute new_user.hashed_password == old_user.hashed_password
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, registration_path(conn, :update, user), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end
end
