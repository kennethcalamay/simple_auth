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

  # scope "/", SimpleAuth do
  #   pipe_through :browser # Use the default browser stack
  #
  # end

  scope "/api", SimpleAuth do
    pipe_through :api

    resources "/registrations", RegistrationController, only: [:create, :show, :update]
    resources "/sessions", SessionController, only: [:create]

    post "/logout", SessionController, :delete
  end
end
