defmodule GithomeWeb.LoginControllerTest do
  use GithomeWeb.ConnCase

  @reg_user %{
    "username" => "user",
    "password" => "pass",
    "confirm-password" => "pass",
    "_csrf_token" => "token"
  }

  @log_user %{
    "username" => "user",
    "password" => "pass",
    "_csrf_token" => "token"
  }

  describe "Register" do

    test "New user" do
      ret = post(build_conn(), "/register", @reg_user)
      assert "/session/new?username=user&token=token" == redirected_to(ret, 302)
    end

    test "Incorrect confirm pass" do
      ret = post(build_conn(), "/register", Map.replace!(@reg_user, "confirm-password", "bad_pass"))
      assert "/" == redirected_to(ret, 302)
    end
  end

  describe "Login" do
    setup do
      post(build_conn(), "/register", @reg_user)
      # |> IO.inspect
      :ok
    end

    test "Auth" do
      ret = post(build_conn(), "/login", @log_user)
      # |> IO.inspect
      assert "/session/new?username=user&token=token" == redirected_to(ret, 302)
    end

    test "Bad Auth: nouser" do
      ret = post(build_conn(), "/login", Map.replace!(@log_user, "username", "nouser"))
      assert "/" == redirected_to(ret, 302)
    end

    test "Bad Auth: incorrect pass" do
      ret = post(build_conn(), "/login", Map.replace!(@log_user, "password", "nopass"))
      assert "/" == redirected_to(ret, 302)
    end
  end
end
