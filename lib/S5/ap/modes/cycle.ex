defmodule Emulation.S5.GenAP.Modes.Cycle do
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.Device
  alias Emulation.S5.AP.GenState, as: State

  def entering(state, _to, _from, _type, _reason) do
    state |> Device.run()
  end

  def on_event(state, _event) do
    state
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
