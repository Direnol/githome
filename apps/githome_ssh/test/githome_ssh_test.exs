defmodule GithomeSshTest do
  use ExUnit.Case
  doctest GithomeSsh

  test "greets the world" do
    assert GithomeSsh.hello() == :world
  end
end
