defmodule Emulation.S5.GenAP.Modes.Run do
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.S5.AP.GenState, as: State
  alias Emulation.Device

  def entering(state, _to, _from, type, _reason) do
    if type != :POPPED do
      state |> State.set_flag(:enable_interrupts, true)
    else
      state
    end
    |> Device.run()
  end

  def on_event(state, _event) do
    state
  end

  def leaving(state, _to, _from, type, _reason) do
    if type in [:POPPED, :SWAPPED] do
      state |> State.set_flag(:enable_interrupts, false)
    else
      state
    end
  end

  def frame(state) do
    state |> PA.push([:ap, :mode], :CYCLE)
  end
end
