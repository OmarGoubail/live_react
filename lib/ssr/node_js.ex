defmodule LiveReact.SSR.NodeJS do
  @moduledoc false
  @behaviour LiveReact.SSR

  def render(name, props) do
    try do
      NodeJS.call!({"server", "render"}, [name, props], binary: true)
    catch
      :exit, {:noproc, _} ->
        message = """
        NodeJS is not configured. Please add the following to your application.ex:
        {NodeJS.Supervisor, [path: LiveReact.SSR.NodeJS.server_path(), pool_size: 4]},
        """

        raise %LiveReact.SSR.NotConfigured{message: message}
    end
  end

  def server_path() do
    {:ok, path} = :application.get_application()
    Application.app_dir(path, "/priv/react")
  end
end
