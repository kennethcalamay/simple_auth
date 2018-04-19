defmodule SimpleAuth.SessionController do
  use SimpleAuth.Web, :controller

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  alias SimpleAuth.User

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    case login(conn, username, password) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render("show.json", session: user)
      {:error, _reason, conn} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "unauthorized"})
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "unauthorized"})
  end

  def delete(conn, %{"session" => %{"token" => session_token}}) do
    user = Repo.get_by(User, %{session_token: session_token})

    if user do
      Repo.update!(User.destroy_session_changeset(user))
      conn
      |> put_status(:ok)
      |> json(%{message: "Successfully logged out."})
    else
      invalid_logout(conn)
    end
  end

  def delete(conn, _params) do
    invalid_logout(conn)
  end

  defp login(conn, username, given_password) do
    user = Repo.get_by(User, username: username)

    cond do
      user && checkpw(given_password, user.hashed_password) ->
        changeset = User.session_changeset(user)
        user = Repo.update!(changeset)
        {:ok, user}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def invalid_logout(conn) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "unauthorized"})
  end
end
