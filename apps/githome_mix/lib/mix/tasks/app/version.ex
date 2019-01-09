defmodule Mix.Tasks.App.Version do
  use Mix.Task

  def run(["--help"]) do
    IO.puts(~s(mix app.version [OPTS]...
    Without args return current version
      --major <vsn> - default 1
      --minor <vsn> - default from git hist
      --patch <vsn> - default 0
      --update - update patch
      --file <file_name> - file with version

    Format vsn: major.minor.patch))
  end

  def run(args) do
    {kw, _argv, []} =
      OptionParser.parse(args,
        strict: [
          major: :integer,
          minor: :integer,
          patch: :integer,
          update: :boolean,
          file: :string
        ],
        aliases: [
          u: :update,
          p: :patch,
          f: :file
        ]
      )

    vsn_file = kw[:file] || "rel/vsn"

    old_vsn =
      if File.exists?(vsn_file) do
        [major, minor, patch] =
          File.read!(vsn_file)
          |> String.split(".")

        [
          major: Integer.parse(major) |> elem(0),
          minor: Integer.parse(minor) |> elem(0),
          patch: Integer.parse(patch) |> elem(0)
        ]
      end || []

    kw = Keyword.merge(old_vsn, kw)

    new_vsn =
      version(
        Keyword.get(kw, :major, 1),
        Keyword.get(kw, :minor, minor_git()),
        Keyword.get(kw, :patch, 0),
        update: kw[:update]
      )

    File.write!(vsn_file, new_vsn)
    IO.puts(new_vsn)
    new_vsn
  end

  defp minor_git do
    System.cmd("git", ~w[rev-list --count HEAD])
    |> elem(0)
    |> String.trim()
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
