defmodule SimpleAuth.RegistrationView do
  use SimpleAuth.Web, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, SimpleAuth.RegistrationView, "user.json")}
  end

  def render("user.json", %{registration: user}) do
    %{
      username: user.username,
      password: "[FILTERED]"
    }
  end
end
