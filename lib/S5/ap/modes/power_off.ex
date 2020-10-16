defmodule Emulators.S5.GenAP.Modes.PowerOff do
  alias Emulators.State, as: ES
  alias Emulators.PushdownAutomaton, as: PA

  def entering(state, _to, _from, _type, _reason) do
    state
    |> Device.idle()
  end

  def on_event(state, :REQUEST_START) do
    state
    |> ES.push(:REQUEST_START)
    |> PA.swap([:ap, :mode], :STOP)
    |> Device.run()
  end

  def on_event(state, _) do
    state
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state) do
    state
  end
end
