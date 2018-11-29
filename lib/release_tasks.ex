defmodule Githome.ReleaseTasks do

@start_apps [
    :crypto,
    :ssl,
    :mariaex,
    :ecto
  ]

@repos Application.get_env(:githome, :ecto_repos, [])

#  def migrate do
#    Application.load(:githome)
#    {:ok, _} = Application.ensure_all_started(:ecto)
#    {:ok, _} = Repo.__adapter__.ensure_all_started(Repo, :temporary)
#    {:ok, _} = Repo.start_link(pool_size: 1)
#
#    path = Application.app_dir(:githome, "priv/repo/migrations")
#
#    Ecto.Migrator.run(Repo, path, :up, all: true)
#
#    :init.stop()
#  end

  defp start_services do
    Enum.each(@start_apps, &Application.ensure_all_started/1)
    Enum.each(@repos, & &1.start_link(pool_size: 1))
  end

  defp stop_services do
    :init.stop()
  end

  def migrate(_argv) do
    start_services()
    run_migrations()
    stop_services()
  end

  defp run_migrations do
    IO.puts("Aplly migrations")
    Enum.each(@repos, &run_migrations_for/1)
  end

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts("Running migrations for #{app}")
    migrations_path = priv_path_for(repo, "migrations")
    Ecto.Migrator.run(repo, migrations_path, :up, all: true)
  end

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)

    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    priv_dir = "#{:code.priv_dir(app)}"

    Path.join([priv_dir, repo_underscore, filename])
  end


end