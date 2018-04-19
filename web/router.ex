defmodule SimpleAuth.Router do
  use SimpleAuth.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", SimpleAuth do
    pipe_through :api

    post "/register", RegistrationController, :create
    post "/login", SessionController, :create
    post "/update_password", RegistrationController, :update

    post "/logout", SessionController, :delete
  end
end
