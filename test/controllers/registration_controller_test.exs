defmodule SimpleAuth.RegistrationControllerTest do
  use SimpleAuth.ConnCase

  alias SimpleAuth.User
  @valid_attrs %{username: "username", password: "password"}
  @token "the token"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "registers user when credentials are valid", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), user: @valid_attrs
    assert json_response(conn, 201)["data"]["username"]
    assert Repo.get_by(User, %{username: "username"})
  end

  test "does not create user when credentials are invalid", %{conn: conn} do
    conn = post conn, registration_path(conn, :create)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not create user when username already exists", %{conn: conn} do
    Repo.insert!(User.registration_changeset(%User{}, @valid_attrs))

    conn = post conn, registration_path(conn, :create), user: @valid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates password when credentials are valid", %{conn: conn} do
    Repo.insert!(%User{username: "username", hashed_password: "dummy hashed password", session_token: @token})

    conn = post conn, registration_path(conn, :update), token: @token, user: %{password: "the new password"}
    assert response(conn, 200)
    refute Repo.get_by(User, %{hashed_password: "dummy hashed password"})
    refute Repo.get_by(User, %{session_token: @token})
  end

  test "does not update when no credentials are given", %{conn: conn} do
    conn = post conn, registration_path(conn, :update), token: @token, user: %{password: "the new password"}
    assert response(conn, 422)
    assert json_response(conn, 422)["error"] == "unauthorized"
  end
end
