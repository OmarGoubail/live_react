defmodule LiveReact.SSR.NotConfigured do
  @moduledoc false

  defexception [:message]
end

defmodule LiveReact.SSR do
  @moduledoc """
  A behaviour for rendering React components server-side.
  """

  @type component_name :: String.t()
  @type props :: %{optional(String.t() | atom) => any}

  @type render_response :: %{
          required(String.t()) => String.t()
        }

  @callback render(component_name, props) :: render_response | no_return

  @spec render(component_name, props) :: render_response | no_return
  def render(name, props) do
    mod = Application.get_env(:live_react, :ssr_module, LiveReact.SSR.NodeJS)

    mod.render(name, props)
  end
end
