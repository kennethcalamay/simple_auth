defmodule SimpleAuth.SessionView do
  use SimpleAuth.Web, :view

  def render("show.json", %{session: session}) do
    %{data: render_one(session, SimpleAuth.SessionView, "session.json")}
  end

  def render("session.json", %{session: session}) do
    %{
      token: session.session_token
    }
  end
end
