defmodule Emulation.S5.AP.Modes.Restart do
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.Emulator.State, as: ES
  alias Emulation.Device

  def entering(state, _to, _from, _type, :BLOCK_RETURN) do
    state
    |> PA.swap([:ap, :mode], :RUN)
    |> Device.run()
  end

  def entering(state, _to, from, _type, _reason) do
    cond do
      from in [:STOP, :START] ->
        state
        |> PA.swap([:ap, :mode], :RUN)
        |> restart

      true ->
        state
    end
  end

  def restart(state) do
    state |> Emulation.S5.AP.Interrupts.Time.restart()
  end

  def on_event(state, event) do
    case event do
      :STOP ->
        state
        |> ES.push(event)
        |> PA.swap([:ap, :mode], :STOP)

      _ ->
        state
    end
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state) do
    state
  end
end
