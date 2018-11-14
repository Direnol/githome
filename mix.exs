defmodule Githome.Mixfile do
  use Mix.Project

  def project do
    [
      app: :githome,
      version: "1.0.0",
      elixir: "~> 1.4",
      description: "Git web",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      package: package()
    ]
  end

  def package do
    [
      maintainer_scripts: [
        pre_install: "config/deb/preinstall",
        post_install: "config/deb/postinstall",
        templates: "config/deb/templates"
      ],
      external_dependencies: ["bash-completion (>= 1:2.8)"],
      codename: lsb_release(),
      license_file: "MIT",
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      config_files: [""],
      maintainers: ["Roman Mingazeev <direnol@yandex.ru>",
                    "Evgeniy Kazartsev",
                    "Michail Popov",
                    "Roman Prokopenko"],
      licenses: ["MIT"],
      vendor: "Sibsutis Students",
      links: %{
        "GitHome" => "https://gitlab.com/evg-kazartseff/githome",
        "Docs" => "https://gitlab.com/evg-kazartseff/githome",
        "Homepage" => "https://gitlab.com/evg-kazartseff/githome"
      }
    ]
  end

  def lsb_release do
    {release, _} = System.cmd("lsb_release", ["-c", "-s"])
    String.replace(release, "\n", "")
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      applications: [:exrm_deb, :phoenix],
      mod: {Githome.Application, []},
      extra_applications: [:logger, :runtime_tools]
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
      {:phoenix, "~> 1.3.4"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:mariaex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:plug_cowboy, "~> 1.0"},
      # cucumber
      {:cabbage, "~> 0.3.0"},
      # capybara
      {:wallaby, "~> 0.20.0", [runtime: false, only: :test]},
      {:exrm, "~> 1.0"},
      {:distillery, "~> 1.4"},
      {:exrm_deb, github: "johnhamelink/exrm_deb", branch: "feature/distillery-support"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
