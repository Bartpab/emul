defmodule Emulation.S5.GenAP.Modes.Stop do
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.Device

  def entering(state, _to, _from, _type, _reason) do
    state
  end

  def on_event(state, :START) do
    state
    |> PA.swap([:ap, :mode], :RESTART)
    |> Device.run()
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state) do
    state
  end
end
