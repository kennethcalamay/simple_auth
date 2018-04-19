defmodule SimpleAuth.RegistrationController do
  use SimpleAuth.Web, :controller

  alias SimpleAuth.User

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render("show.json", user: user)
      {:error, _} ->
        create(conn, nil)
    end
  end

  def create(conn, _params) do
    changeset = User.registration_changeset(%User{})

    conn
    |> put_status(:unprocessable_entity)
    |> render(SimpleAuth.ChangesetView, "error.json", changeset: changeset)
  end

  def update(conn, %{"token" => session_token, "user" => %{"password" => the_new_password}}) do
    user = Repo.get_by(User, %{session_token: session_token})

    if user do
      changeset = User.password_reset_changeset(user, %{password: the_new_password})
      case Repo.update(changeset) do
        {:ok, user} ->
          render(conn, "show.json", user: user)
        {:error, _} ->
          render_invalid_update(conn)
      end
    else
      render_invalid_update(conn)
    end
  end

  def render_invalid_update(conn) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "unauthorized"})
  end
end
