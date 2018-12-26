defmodule Mix.Tasks.App.Version do
  use Mix.Task

  def update vsn do
    [major, minor, old_patch] = String.split vsn, "."
    {patch, _} = Integer.parse old_patch
    "#{major}.#{minor}.#{patch + 1}"
  end

  def run([]) do
    vsn = Mix.Project.config[:version]
    |>IO.puts
  end

  def run(["update"]) do
    vsn = Mix.Project.config[:version]
    |> update
    File.write "rel/vsn", vsn
    IO.puts vsn
  end
end
