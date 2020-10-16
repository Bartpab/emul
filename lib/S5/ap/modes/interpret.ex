defmodule Emulators.S5.GenAP.Modes.Interpret do
  def entering(state, _to, _from, _type, _reason) do
    state
    |> Device.run()
  end

  def on_event(state, _event) do
    state
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state) do
    state = state |> State.next_instr()
    instr = state |> State.current_instr()

    state =
      state
      |> Dispatcher.dispatch(State, instr)
  end
end
