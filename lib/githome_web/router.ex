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

  pipeline :main_layout do
    plug :put_layout, {GithomeWeb.LayoutView, :main}
  end

  pipeline :reg_layout do
    plug :put_layout, {GithomeWeb.LayoutView, :reg}
  end

  pipeline :reg_layout do
    plug :put_layout, {GithomeWeb.LayoutView, :reg}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GithomeWeb do
    pipe_through [:browser, :reg_layout]

    get "/", LoginController, :index
    post "/login", LoginController, :login
    post "/register", LoginController, :register
    get "/customize", LoginController, :customize
  end

  scope "/session", GithomeWeb do
    pipe_through :browser

    get "/new", SessionController, :new
    get "/logout", SessionController, :logout
  end

  scope "/my_projects", GithomeWeb do
    pipe_through [:browser, :main_layout]

    get "/", MyProjectController, :index
    get "/add", MyProjectController, :add
  end

  scope "/users", GithomeWeb do
    pipe_through [:browser, :main_layout]

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
  end

  scope "/settings", GithomeWeb do
    pipe_through [:browser, :main_layout]

    get "/", ParameterController, :index
    get "/show", ParameterController, :show
    get "/edit", ParameterController, :edit
    delete "/delete", ParameterController, :delete
    get "/new", ParameterController, :new
    post "/create", ParameterController, :create
    post "/update", ParameterController, :update
  end

  scope "/projects", GithomeWeb do
    pipe_through [:browser, :main_layout]

    get "/", ProjectController, :index
    get "/show", ProjectController, :show
    get "/edit", ProjectController, :edit
    delete "/delete", ProjectController, :delete
    get "/new", ProjectController, :new
    post "/create", ProjectController, :create
    post "/update", ProjectController, :update
  end

  scope "/groups", GithomeWeb do
    pipe_through [:browser, :main_layout]

    get "/", GroupController, :index
    get "/show", GroupController, :show
    get "/edit", GroupController, :edit
    delete "/delete", GroupController, :delete
    get "/new", GroupController, :new
    post "/create", GroupController, :create
    post "/update", GroupController, :update
  end
#   Other scopes may use custom stacks.
   scope "/api", GithomeWeb do
     pipe_through :api
   end
end
