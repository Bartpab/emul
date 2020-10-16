defmodule Emulators.S5.GenAP.Modes.Cycle do
  def entering(state, to, from, type, reason) do
    if GenState.has_block(:OB, 1) do
      state
      |> GenState.call(:OB, 1)
    end

    state
  end

  def on_event(state, _event) do
    state
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state) do
    state
    |> Device.run()
  end
end
