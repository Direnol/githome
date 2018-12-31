defmodule GithomeShellTest do
  use ExUnit.Case
  doctest GithomeShell

  test "greets the world" do
    assert GithomeShell.hello() == :world
  end
end
