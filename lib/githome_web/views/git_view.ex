defmodule GithomeWeb.GitView do
  use GithomeWeb, :view

  def actions do
    [
      :status,
      :log,
      :create_user,
      :commit,
      :add,
      :push,
      :render,
      :create_project,
      :update_conf
    ]
  end

  defp home_dir() do
    case Application.get_env(:githome, :env) do
      :prod -> System.user_home()
      _ -> "/home/githome"
    end
  end

  defp cmd(command, args, opts \\ []) do
    {ret, err} =
      System.cmd(command, args, [cd: home_dir() <> "/admin", stderr_to_stdout: true] ++ opts)

    {err, ret}
  end

  @doc """

    ## Examples

    iex> GithomeWeb.GitView.git :render, groups: [{"admins", ["admin", "direnol"]}, {"users", ["u1", "u2"]}], repos: [{"gitolite-admin", [RW: ["@admins"]]}]
    "@admins =  admin  direnol \n@users =  u1  u2 \n\nrepo gitolite-admin\n    RW+ =  @admins \n        \n"


  """
  def git(action, opts \\ []) do
    if action in actions() do
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
    "conf"
    |> render(
      groups: opts[:groups],
      repos: opts[:repos]
    )
  end

  defp git_action(:log, _opts) do
    cmd("git", ["log"])
  end

  defp git_action(:push, _opts) do
    cmd("git", ["push"])
  end

  defp git_action(:update_conf, opts) do
    opts[:file]
    |> File.write(opts[:data])
  end

  defp git_action(act, _opts) do
    {:ok, act}
  end
end
