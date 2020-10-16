defmodule Emulators.S5.GenAP.Modes.Stop do
  def entering(state, _to, _from, _type, _reason) do
    state
    |> Device.idle()
  end

  def on_event(state, :REQUEST_START) do
    state
    |> PA.swap(:RESTART)
    |> Device.run()
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state) do
    state
  end
end
