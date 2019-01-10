defmodule GithomeWeb.ApiView do
  use GithomeWeb, :view

  @template "render.json"

  def render "index.json", %{api: list} do
    Enum.with_index(list)
    |> Enum.map(fn {v, k} -> {k, v} end)
    |> Enum.into(%{})
  end

  def render @template, %{error: true} do
    %{error: 400}
  end

  def render @template, %{users: users} do
    for u <- users, into: %{} do
      {u.id, %{
        username: u.username
      }}
    end
    |> IO.inspect
  end

  def render @template, %{projects: projects} do
    for p <- projects, into: %{} do
      {p.id, %{
        project_name: p.project_name
      }}
    end
    |> IO.inspect
  end
end
