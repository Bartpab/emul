defmodule Emulators.S5.GenAP.Modes.External do
  def entering(state, _to, _from, _type, _reason) do
    state
  end

  def on_event(state, _event) do
    state
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state) do
    state
    |> Device.run()
  end
end
