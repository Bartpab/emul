defmodule Emulators.S5.GenAP.Modes.Default do
  def entering(state, _to, _from, _type, _reason) do
    state
  end

  def on_event(state, event) do
    state
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state, event) do
    state
  end
end
