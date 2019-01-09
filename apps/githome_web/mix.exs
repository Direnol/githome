defmodule GithomeWeb.Mixfile do
  use Mix.Project

  @major_vsn "1"
  @minor_vsn "0"
  @patch_vsn "0"

  def project do
    [
      app: :githome_web,
      version: "#{@major_vsn}.#{@minor_vsn}.#{@patch_vsn}",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {GithomeWeb.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :ssl,
        :xmerl,
        :comeonin
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:navigation_history, "~> 0.0"},
      {:githome, in_umbrella: true},
      {:githome_ssh, in_umbrella: true},
      {:ex_machina, github: "thoughtbot/ex_machina"},
      {:phoenix_integration, "~> 0.6.0", only: :test}
      # {:wallaby, "~> 0.21", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, we extend the test task to create and migrate the database.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [test: ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
