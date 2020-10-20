defmodule Emulation.S5.GenAP.Modes.Restart do
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.Device

  def entering(state, _to, _from, _type, :BLOCK_RETURN) do
    state
    |> PA.swap([:ap, :mode], :RUN)
    |> Device.run()
  end

  def entering(state, _to, :STOP, _type, _reason) do
    state
    |> PA.swap([:ap, :mode], :RUN)
    |> Device.run()
  end

  def on_event(state, _event) do
    state
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state) do
    state
  end
end
