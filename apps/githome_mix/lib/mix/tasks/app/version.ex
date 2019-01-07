defmodule Mix.Tasks.App.Version do
  use Mix.Task

  @vsn_file "rel/vsn"

  def run([]) do
    raise "Need arguments"
  end

  def run(args) do
    {kw, _argv, []} =
      OptionParser.parse(args,
        strict: [
          major: :integer,
          minor: :integer,
          patch: :integer,
          save: :boolean,
          update: :boolean,
          read: :boolean
        ],
        aliases: [
          u: :update,
          p: :patch,
          r: :read
        ]
      )
      |> IO.inspect()

    kw =
      if kw[:read] && File.exists?(@vsn_file) do
        [major, minor, patch] =
          File.read!(@vsn_file)
          |> String.split(".")

        Map.merge(kw, %{
          major: Integer.parse(major),
          minor: Integer.parse(minor),
          patch: Integer.parse(patch)
        })
      else
        kw
      end

    new_vsn =
      version(
        Map.get(kw, :major, 1),
        Map.get(kw, :minor, nil),
        Map.get(kw, :patch, 0),
        update: kw[:update]
      )

    File.write!(@vsn_file, new_vsn)
  end

  defp version(major, minor, patch, kw) do
    minor =
      if minor == nil do

      else
        minor
      end

    if kw[:update] do
      "#{major}.#{minor}.#{patch + 1}"
    else
      "#{major}.#{minor}.#{patch}"
    end
  end
end
