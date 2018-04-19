defmodule SimpleAuth.UserTest do
  use SimpleAuth.ModelCase

  alias SimpleAuth.User

  @valid_attrs %{username: "username", password: "password"}
  @invalid_attrs %{}

  test "registration changeset with valid attributes" do
    changeset = User.registration_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "registration changeset with invalid attributes" do
    changeset = User.registration_changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "password reset changeset with valid attributes" do
    changeset = User.password_reset_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "password reset changeset with invalid attributes" do
    changeset = User.password_reset_changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
