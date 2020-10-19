defmodule Emulation.S5.GenAP.Modes.PowerOff do
  alias Emulation.Emulator.State, as: ES
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.Device

  def entering(state, _to, _from, _type, _reason) do
    state
  end

  def on_event(state, :START) do
    state
    |> PA.swap([:ap, :mode], :STOP)
    |> ES.push(:START)
  end

  def on_event(state, event) do
    state
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state) do
    state
  end
end