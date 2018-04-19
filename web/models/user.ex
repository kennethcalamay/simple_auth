defmodule SimpleAuth.User do
  use SimpleAuth.Web, :model

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true

    field :hashed_password, :string

    timestamps()
  end

  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :password])
    |> validate_required([:username, :password])
  end

  def password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:password])
    |> validate_required([:password])
    |> put_hashed_password()
  end

  defp put_hashed_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :hashed_password, Comeonin.Bcrypt.hashpwsalt(password))

      _ ->
        changeset
    end
  end
end
