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
      deb_package: package()
    ]
  end

  def package do
    [
      maintainer_scripts: [
        pre_install: "rel/distillery_packager/debian/preinstall",
        post_install: "rel/distillery_packager/debian/postinstall",
        pre_uninstall: "rel/distillery_packager/debian/prerm",
        post_uninstall: "rel/distillery_packager/debian/postrm",
        templates: "rel/distillery_packager/debian/templates",
        config: "rel/distillery_packager/debian/config"
      ],
      external_dependencies: [
        "bash-completion (>= 1:2.8)",
        "mysql-server (>= 5.7)",
        "elixir (>= 1.7.3-1)"
      ],
      codename: lsb_release(System.get_env("IN_DOCKER")),
      license_file: "MIT",
      files: ["lib", "mix.exs", "README*", "LICENSE"],
      config_files: ["/etc/githome/config.json"],
      maintainers: [
        "Roman Mingazeev <direnol@yandex.ru>",
        "Evgeniy Kazartsev <evg.kazartseff@yandex.ru>",
        "Michail Popov",
        "Roman Prokopenko"
      ],
      licenses: ["MIT"],
      vendor: "Sibsutis Students",
      homepage: "https://gitlab.com/evg-kazartseff/githome",
      base_path: "/opt",
      additional_files: [
        {"etc", "/etc/githome"},
        {"data", "/var/lib/githome"}
      ],
      owner: [user: "root", group: "root"]
    ]
  end

  def lsb_release(env) do
    case env do
      nil ->
        {release, _} = System.cmd("lsb_release", ["-c", "-s"])
        String.replace(release, "\n", "")

      _ ->
        "bionic"
    end
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      applications: [:phoenix],
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
      {:distillery_packager, "~> 1.0"},
      {:artificery, "~> 0.2.6"},
      {:ex_app_info, "~> 0.3.0"}
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
