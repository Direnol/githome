defmodule GithomeWeb.Router do
  use GithomeWeb, :router

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

  scope "/", GithomeWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/users", GithomeWeb do
    pipe_through :browser

    get "/", UserController, :index
    get "/show", UserController, :show
    get "/edit", UserController, :edit
    delete "/delete", UserController, :delete
    get "/new", UserController, :new
    post "/create", UserController, :create
    post "/update", UserController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", GithomeWeb do
  #   pipe_through :api
  # end
end
