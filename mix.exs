defmodule Githome.MixProject do
  use Mix.Project

  @major_vsn "1"

  def project do
    [
      app: :githome,
      version: version(),
      elixir: "~> 1.5",
      description: "Git web",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      deb_package: package()
    ]
  end

  def version do
    now = DateTime.utc_now()

    {:ok, last} =
      System.cmd("git", ~w[log --pretty=%at -1])
      |> elem(0)
      |> Integer.parse()
      |> elem(0)
      |> DateTime.from_unix()

    patch = DateTime.diff(now, last)
    {minor, 0} = System.cmd("git", ~w[rev-list --count HEAD])
    @major_vsn <> "." <> String.trim(minor) <> "." <> to_string(patch)
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Githome.Application, []},
      extra_applications: [
        :logger,
        :runtime_tools,
        :ssl,
        :xmerl,
        :comeonin
      ],
      env: [env: Mix.env()]
    ]
  end

  def package do
    [
      maintainer_scripts: [
        pre_install: "rel/distillery_packager/debian/preinstall",
        post_install: "rel/distillery_packager/debian/postinstall",
        pre_uninstall: "rel/distillery_packager/debian/prerm",
        post_uninstall: "rel/distillery_packager/debian/postrm",
        templates: "rel/distillery_packager/debian/template",
        config: "rel/distillery_packager/debian/config"
      ],
      external_dependencies: [
        "bash-completion (>= 1:2.8)",
        "mysql-server (>= 5.7)",
        "elixir (>= 1.7.3-1)",
        "git",
        "adduser",
        "libjson-perl",
        "openssh-client",
        "openssh-server | ssh-server",
        "perl"
      ],
      codename: lsb_release(),
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
        {"etc", "/etc"},
        {"var", "/var"},
        {"usr", "/usr"}
      ],
      owner: [user: "githome", group: "githome"]
    ]
  end

  def lsb_release do
    {release, _} = System.cmd("lsb_release", ["-c", "-s"])
    String.replace(release, "\n", "")
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
      {:ecto_sql, "~> 3.0"},
      {:mariaex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:distillery_packager, "~> 1.0"},
      {:comeonin, "~> 2.3"},
      {:navigation_history, "~> 0.0"}
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
