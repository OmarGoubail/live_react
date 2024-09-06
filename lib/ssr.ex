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
          "html" => String.t(),
          "head" => String.t(),
          "css" => %{"code" => String.t(), "map" => String.t()}
        }

  @callback render(component_name, props) :: render_response | no_return

  @spec render(component_name, props) :: render_response | no_return
  def render(name, props) do
    mod = Application.get_env(:live_react, :ssr_module, LiveReact.SSR.NodeJS)

    case mod.render(name, props) do
      %{"html" => html, "head" => head, "css" => css} = response ->
        response
      _ ->
        raise "Invalid SSR response format"
    end
  end
end
