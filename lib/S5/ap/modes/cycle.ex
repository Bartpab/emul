defmodule Emulation.S5.AP.Modes.Cycle do
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.S5.AP.State, as: State
  alias Emulation.Emulator.State, as: ES

  def entering(state, _to, _from, _type, _reason) do
    state
  end

  def on_event(state, event) do
    case event do
      :RESTART ->
        state
        |> ES.push(event)
        |> PA.pop([:ap, :mode])

      :STOP ->
        state
        |> ES.push(event)
        |> PA.pop([:ap, :mode])

      _ ->
        state
    end
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def execute_cycle(state) do
    if State.has_block(state, :OB, 1) do
      state
      |> State.call(:OB, 1)
    else
      state
    end
  end

  def frame(state) do
    if PA.current(state, [:ap, :exe]) == :DEFAULT do
      state |> execute_cycle()
    else
      state
    end
  end
end
