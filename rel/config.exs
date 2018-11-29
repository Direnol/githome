
#Path.join(["rel", "plugins", "*.exs"])
#|> Path.wildcard()
#|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  # This sets the default release built by `mix release`
  default_release: :default,
  # This sets the default environment used by `mix release`
  default_environment: Mix.env()

environment :dev do
  set(dev_mode: true)
  set(include_erts: false)
  set cookie: File.read!("config/cookie.txt") |> String.to_atom
  set vm_args: "rel/vm.args.eex"
end

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set cookie: File.read!("config/cookie.txt") |> String.to_atom
  set vm_args: "rel/vm.args.eex"
end

release :githome do
  set(version: current_version(:githome))
  plugin DistilleryPackager.Plugin
  set(
    applications: [
      :githome
    ]
  )
  set commands: [
        db_init:      "rel/commands/db-init.sh",
#        db_reset:     "rel/commands/db-reset.sh",
#        db_remove:    "rel/commands/db-remove.sh",
        db_migrate:   "rel/commands/db-migrate.sh"
#        db_new_admin: "rel/commands/db-new-admin.sh",
#        db_rm_admin:  "rel/commands/db-rm-admin.sh"
      ]
end
