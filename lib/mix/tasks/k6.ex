defmodule Mix.Tasks.K6 do
  @moduledoc """
  Runs k6 commands

  The command runs using the binary installed locally in the `_build` folder of the project.
  If k6 is not installed for the local project, it will automatically install it before running the command.

  k6 is be executed inside the `priv/k6` folder of your project, where k6 tests reside.

  ## Examples

      $ mix k6 run my_test.js
  """
  use Mix.Task

  @binary_path Path.join(Path.dirname(Mix.Project.build_path()), "k6")

  @shortdoc "Runs k6"
  def run(args) when is_list(args) do
    unless File.exists?(@binary_path), do: Mix.Task.run("k6.install")

    test_dir = Path.join(["priv", "k6"])
    unless File.exists?(test_dir), do: File.mkdir_p(test_dir)

    opts = [
      cd: test_dir,
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true,
      env: k6_env()
    ]

    command = @binary_path <> " " <> Enum.join(args, " ")
    Mix.shell().cmd(command, opts)
  end

  defp k6_env() do
    stringify_key = fn {k, v} -> {to_string(k), v} end

    :k6
    |> Application.get_env(:env, [])
    |> Enum.into([], stringify_key)
  end
end
