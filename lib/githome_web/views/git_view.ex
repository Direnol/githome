defmodule GithomeWeb.GitView do
  use GithomeWeb, :view

  @doc """

    ## Examples

      iex> GithomeWeb.GitView.git_render "project" repo: {"gitolite-admin", [RW: ["@admins"]]}

      iex> GithomeWeb.GitView.git_render "project" group: {"admins", ["admin", "direnol"]}, {"users", ["u1", "u2"]},

  """
  def git_render(template, opts) do
    template
    |> render(opts)
  end
end
