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

  @doc """
  Changeset for user registration
  """
  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length(:password, min: 8, max: 32)
    |> unique_constraint(:username)
    |> put_hashed_password()
  end

  @doc """
  Changeset for user password change
  """
  def password_reset_changeset(struct, params \\ %{}) do
    struct
    |> registration_changeset(params)
    |> remove_session_token()
  end

  @doc """
  Changeset for login
  """
  def session_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> assign_session_token()
  end

  # utility functions

  # for creating a hashed version of the password
  defp put_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :hashed_password, Comeonin.Bcrypt.hashpwsalt(password))

      _ ->
        changeset
    end
  end

  # token assigning: login
  defp assign_session_token(changeset) do
    put_change(changeset, :session_token, generate_token(@token_length))
  end

  # token removal (logout): password change
  defp remove_session_token(changeset) do
    put_change(changeset, :session_token, nil)
  end

  # function for generating token
  defp generate_token(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode16()
    |> binary_part(0, length)
  end
end
