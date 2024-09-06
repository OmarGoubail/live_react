defmodule LiveReact do
  use Phoenix.Component
  import Phoenix.HTML

  @moduledoc """
  See READ.md for installation instructions and examples.
  """

  @doc """
  Render a React component.
  """
  def react(assigns) do
    {props, props_changed?} = extract(assigns, :props)
    ssr_render = if assigns[:ssr] != false, do: LiveReact.SSR.render(assigns.name, props), else: nil

    assigns =
      assigns
      |> Map.put_new(:class, nil)
      |> Map.put(:__component_name, Map.get(assigns, :name))
      |> Map.put(:props, props)
      |> Map.put(:ssr_render, ssr_render)

    computed_changed = %{
      props: props_changed?
    }

    assigns =
      update_in(assigns.__changed__, fn
        nil -> nil
        changed -> for {k, true} <- computed_changed, into: changed, do: {k, true}
      end)

    ~H"""
    <div
      id={assigns[:id] || id(@__component_name)}
      data-name={@__component_name}
      data-props={"#{json(@props)}"}
      data-ssr={@ssr_render != nil}
      phx-update="ignore"
      phx-hook="ReactHook"
      class={@class}
    >
      <%= if @ssr_render do %>
        <%= raw(@ssr_render["html"]) %>
      <% end %>
    </div>
    """
  end

  defp extract(assigns, type) do
    Enum.reduce(assigns, {%{}, false}, fn {key, value}, {acc, changed} ->
      case normalize_key(key, value) do
        ^type -> {Map.put(acc, key, value), changed || key_changed(assigns, key)}
        _ -> {acc, changed}
      end
    end)
  end

  defp normalize_key(key, _val) when key in ~w(id class name socket __changed__ __given__)a,
    do: :special

  defp normalize_key(key, val) when is_atom(key), do: key |> to_string() |> normalize_key(val)
  defp normalize_key(_key, _val), do: :props

  defp key_changed(%{__changed__: nil}, _key), do: true
  defp key_changed(%{__changed__: changed}, key), do: changed[key] != nil

  defp json(props) do
    Jason.encode!(props)
  end

  defp id(name), do: "#{name}-#{System.unique_integer([:positive])}"
end
