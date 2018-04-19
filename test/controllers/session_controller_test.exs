defmodule SimpleAuth.SessionControllerTest do
  use SimpleAuth.ConnCase

  alias SimpleAuth.User

  @valid_attrs %{username: "username", password: "password"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates session when credentials are valid", %{conn: conn} do
    Repo.insert!(User.registration_changeset(%User{}, @valid_attrs))

    conn = post conn, session_path(conn, :create), session: @valid_attrs

    token = json_response(conn, 201)["data"]["token"]
    assert token
    assert Repo.get_by(User, session_token: token)
  end

  test "does not create session when wrong password are given", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{username: "username", password: "wrong password"}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not create session when user does not exist", %{conn: conn} do
    conn = post conn, session_path(conn, :create), session: %{username: "wrong username", password: "password doesn't matter"}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not create session when no credentials are given", %{conn: conn} do
    conn = post conn, session_path(conn, :create)
    assert json_response(conn, 422)["errors"] != %{}
  end

end
