defmodule GithomeSsh.MixProject do
  use Mix.Project

  @major_vsn "1"
  @minor_vsn "0"
  @patch_vsn "0"

  def project do
    [
      app: :githome_ssh,
      version: "#{@major_vsn}.#{@minor_vsn}.#{@patch_vsn}",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:rsa_ex],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:sshex, "2.2.1"},
      {:rsa_ex, "~> 0.4"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true},
    ]
  end
end
