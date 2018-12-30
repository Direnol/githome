defmodule Githome.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      description: "Git web",
      start_permanent: Mix.env() == :prod,
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
        {"usr", "/usr"},
        {"bin", "/bin"}
      ],
      owner: [user: "githome", group: "githome"]
    ]
  end

  def lsb_release do
    {release, _} = System.cmd("lsb_release", ["-c", "-s"])
    String.replace(release, "\n", "")
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:distillery_packager, "~> 1.0"}
    ]
  end
end
