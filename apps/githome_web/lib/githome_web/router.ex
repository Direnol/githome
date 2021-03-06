defmodule GithomeWeb.Router do
  use GithomeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug NavigationHistory.Tracker
  end

  pipeline :verify do
    plug GithomeWeb.CheckAuth, :verify
  end

  pipeline :main_layout do
    plug :put_layout, {GithomeWeb.LayoutView, :main}
  end

  pipeline :reg_layout do
    plug :put_layout, {GithomeWeb.LayoutView, :reg}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GithomeWeb do
    pipe_through ~w[browser reg_layout]a

    get "/", LoginController, :index
    post "/login", LoginController, :login
    post "/register", LoginController, :register
  end

  scope "/session", GithomeWeb do
    pipe_through ~w[browser verify]a

    get "/new", SessionController, :new
    get "/logout", SessionController, :logout
  end

  scope "/my_projects", GithomeWeb do
    pipe_through ~w[browser main_layout verify]a

    get "/", MyProjectController, :index
    get "/new", MyProjectController, :new
    get "/show", MyProjectController, :show
    get "/edit", MyProjectController, :edit
    get "/view", MyProjectController, :view
    get "/log", MyProjectController, :log
    delete "/delete", MyProjectController, :delete
    post "/create", MyProjectController, :create
    post "/update", MyProjectController, :update
    put "/update", MyProjectController, :update
  end

  scope "/users", GithomeWeb do
    pipe_through ~w[browser main_layout verify]a

    get "/", UserController, :index
    get "/show", UserController, :show
    get "/edit", UserController, :edit
    delete "/delete", UserController, :delete
    get "/new", UserController, :new
    post "/create", UserController, :create
    post "/update", UserController, :update
    put "/update", UserController, :update
    get "/change_password", UserController, :change_password
    post "/change_password", UserController, :change_password_post
    post "/change_admin", UserController, :admin
  end

  scope "/settings", GithomeWeb do
    pipe_through ~w[browser main_layout verify]a

    get "/", ParameterController, :index
    get "/show", ParameterController, :show
    get "/edit", ParameterController, :edit
    delete "/delete", ParameterController, :delete
    get "/new", ParameterController, :new
    post "/create", ParameterController, :create
    post "/update", ParameterController, :update
  end

  scope "/projects", GithomeWeb do
    pipe_through ~w[browser main_layout verify]a

    get "/", ProjectController, :index
    get "/show", ProjectController, :show
    get "/edit", ProjectController, :edit
    delete "/delete", ProjectController, :delete
    get "/new", ProjectController, :new
    post "/create", ProjectController, :create
    post "/update", ProjectController, :update
  end

  scope "/groups", GithomeWeb do
    pipe_through ~w[browser main_layout verify]a

    get "/", GroupController, :index
    get "/show", GroupController, :show
    get "/edit", GroupController, :edit
    delete "/delete", GroupController, :delete
    get "/new", GroupController, :new
    post "/create", GroupController, :create
    post "/update", GroupController, :update
  end

  scope "/my_groups", GithomeWeb do
    pipe_through ~w[browser main_layout verify]a

    get "/", MyGroupController, :index
    get "/show", MyGroupController, :show
    get "/edit", MyGroupController, :edit
    delete "/delete", MyGroupController, :delete
    get "/new", MyGroupController, :new
    post "/create", MyGroupController, :create
    post "/update", MyGroupController, :update
    put "/update", MyGroupController, :update
  end

  #   Other scopes may use custom stacks.
  scope "/api", GithomeWeb do
    pipe_through ~w[api]a
    resources "/", ApiController
  end
end
