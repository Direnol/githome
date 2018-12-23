defmodule Githome.Git do
  import EEx

  @actions [
    :status,
    :log,
    :create_user,
    :commit,
    :add,
    :push,
    :render,
    :create_project
  ]

  defp home_dir() do
    case Application.get_env(:githome, :env) do
      :prod -> System.user_home()
      _ -> "/home/githome"
    end
  end

  @root "lib/githome_web/templates"

  defp cmd(command, args, opts \\ []) do
    {ret, err} =
      System.cmd(command, args, [cd: home_dir() <> "/admin", stderr_to_stdout: true] ++ opts)

    {err, ret}
  end

  def git(action, opts \\ []) do
    if action in @actions do
      git_action(action, opts)
    else
      {:error, bad_arg: action}
    end
  end

  defp git_action(:create_user, opts) do
    user = opts[:username]
    ssh_pub = opts[:ssh]
    ssh_file = home_dir() <> "/admin/keydir/" <> user <> ".pub"

    ret =
      case ssh_file
           |> File.open([:write]) do
        {:ok, file} ->
          IO.puts(file, ssh_pub)
          File.close(file)
          :ok

        {:error, fail} ->
          {:error, fail}
      end

    case ret do
      {:error, _} ->
        ret

      _ ->
        git_action(:add, ssh_file)
        git_action(:commit, message: "Create user " <> user)
    end
  end

  defp git_action(:commit, opts) do
    cmd("git", ["commit", "-m", opts[:message]])
  end

  defp git_action(:status, _opts) do
    cmd("git", ["status"])
  end

  defp git_action(:add, file) do
    cmd("git", ["add", file])
  end

  defp git_action(:render, opts) do
    {:ok, file} = File.open(home_dir() <> "/admin/conf/gitolite.conf", [:write])

    render =
      eval_file(@root <> "/git/gitolite.conf.eex",
        assigns: [
          groups: opts[:groups],
          repos: opts[:repos]
        ]
      )
      |> IO.inspect()

    IO.puts(file, render)

    File.close(file)
  end

  defp git_action(:log, _opts) do
    cmd("git", ["log"])
  end

  defp git_action(:push, _opts) do
    cmd("git", ["push"])
  end

  defp git_action(act, _opts) do
    {:ok, act}
  end
end
