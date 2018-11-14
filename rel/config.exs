Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  # This sets the default release built by `mix release`
  default_release: :default,
  # This sets the default environment used by `mix release`
  default_environment: Mix.env()

environment :dev do
  set(dev_mode: true)
  set(include_erts: false)
end

environment :prod do
  set(include_erts: true)
  set(include_src: false)
end

release :githome do
  set(version: current_version(:githome))
  plugin DistilleryPackager.Plugin
  set(
    applications: [
      :githome
    ]
  )
end
