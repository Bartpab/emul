defmodule Emulation.S5.AP.Modes.Default do
  alias Emulation.Device

  def entering(state, _to, _from, _type, _reason) do
    state
    |> Device.idle()
  end

  def on_event(state, _event) do
    state
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state, _event) do
    state
  end
end
