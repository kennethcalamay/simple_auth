defmodule SimpleAuth.User do
  use SimpleAuth.Web, :model

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true

    field :hashed_password, :string
    field :session_token, :string

    timestamps()
  end

  @token_length 32

  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> unique_constraint(:username)
    |> put_hashed_password()
  end

  def password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:password])
    |> validate_required([:password])
    |> put_hashed_password()
  end

  def session_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> assign_session_token()
  end

  def destroy_session_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> remove_session_token()
  end

  defp put_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :hashed_password, Comeonin.Bcrypt.hashpwsalt(password))

      _ ->
        changeset
    end
  end

  defp assign_session_token(changeset) do
    put_change(changeset, :session_token, generate_token(@token_length))
  end

  defp remove_session_token(changeset) do
    put_change(changeset, :session_token, nil)
  end

  defp generate_token(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode16()
    |> binary_part(0, length)
  end
end
