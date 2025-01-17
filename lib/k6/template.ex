defmodule K6.Template do
  @moduledoc """
  Utility functions for a k6 template
  """
  @default_host_and_port {"localhost", 80}

  @callback needs_utilities() :: [String.t()]
  @callback create(filename :: String.t(), opts :: keyword) :: boolean()

  defmacro __using__(_) do
    quote do
      import Mix.Generator
      import K6.Template

      @behaviour K6.Template

      @impl true
      def needs_utilities, do: []

      defoverridable needs_utilities: 0

      @spec generate_and_save(binary, keyword) :: :ok
      def generate_and_save(filename, opts) do
        directory_path = Path.dirname(filename)

        unless File.exists?(directory_path), do: create_directory(directory_path)
        K6.Utilities.create(directory_path, needs_utilities())
        create(filename, opts)
        :ok
      end
    end
  end

  def template_path(template) do
    Path.join([Application.app_dir(:k6), "priv/templates/", template])
  end

  def default_host_and_port do
    mix_app = Mix.Project.config()[:app]
    config = Application.get_all_env(mix_app)

    phoenix_endpoint =
      config
      |> Enum.map(fn {key, _value} -> key end)
      |> Enum.find(&phoenix_endpoint?/1)

    if phoenix_endpoint != nil do
      uri = phoenix_endpoint.struct_url()
      {uri.host, uri.port}
    else
      @default_host_and_port
    end
  end

  defp phoenix_endpoint?(term) do
    endpoint_name? = "Endpoint" == term |> Module.split() |> Enum.at(-1)
    has_url_function? = Keyword.has_key?(term.__info__(:functions), :struct_url)

    endpoint_name? && has_url_function?
  rescue
    _ -> false
  end
end
