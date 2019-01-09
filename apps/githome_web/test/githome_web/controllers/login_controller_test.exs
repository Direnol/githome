defmodule GithomeWeb.LoginControllerTest do
  use GithomeWeb.ConnCase

  use PhoenixIntegration

  @reg_user %{
    username: "user",
    password:  "pass",
    confirm: "pass",
    _csrf_token: "token"
  }

  @log_user %{
    username: "user",
    password: "pass",
    _csrf_token: "token"
  }

  describe "Register" do
    test "New user" do
      get(build_conn(), "/")
      |> follow_form(@reg_user, identifier: "#register-form")
      |> assert_response(path: "/my_projects")
      end

    test "Incorrect confirm pass" do
      get(build_conn(), "/")
      |> follow_form(Map.replace!(@reg_user, :password, "pas"), identifier: "#register-form")
      |> assert_response(path: "/", assigns: %{info: "Check your password"})
    end
  end

  describe "Login" do
    setup do
      post(build_conn(), "/register", @reg_user)
      :ok
    end

    test "Auth" do
      get(build_conn(), "/")
      |> follow_form(@log_user, identifier: "#login-form")
      |> assert_response(path: "/my_projects")
    end

    test "Bad Auth: nouser" do
      get(build_conn(), "/")
      |> follow_form(Map.replace!(@log_user, :username, "nouser"), identifier: "#login-form")
      |> assert_response(path: "/", assigns: %{info: "Incorrected password or username."})
    end

    test "Bad Auth: incorrect pass" do
      get(build_conn(), "/")
      |> follow_form(Map.replace!(@log_user, :password, "pas"), identifier: "#login-form")
      |> assert_response(path: "/", assigns: %{info: "Incorrected password or username."})
    end
  end
end
