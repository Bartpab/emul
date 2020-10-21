defmodule Emulation.S5.AP.Services.Edges do
  alias Emulation.S5.AP.StateDispatcher, as: State

  def process(state, old_state) do
    state |> State.set_edge(:RLO, State.get(state, :RLO) - State.get(old_state, :RLO))
  end
end
