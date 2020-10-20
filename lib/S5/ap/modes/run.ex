defmodule Emulation.S5.AP.Modes.Run do
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.S5.AP.State, as: State
  alias Emulation.Emulator.State, as: ES
  alias Emulation.Device

  def entering(state, _to, _from, type, _reason) do
    if type != :POPPED do
      state |> State.set_flag(:enable_interrupts, true)
    else
      state
    end
    |> Device.run()
  end

  def on_event(state, event) do
    case event do
      :RESTART ->
        state
        |> ES.push(event)
        |> PA.swap([:ap, :mode], :RESTART)

      :STOP ->
        state
        |> ES.push(event)
        |> PA.swap([:ap, :mode], :STOP)

      _ ->
        state
    end
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
