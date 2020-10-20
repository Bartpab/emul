defmodule Emulation.S5.AP.Modes.Stop do
  alias Emulation.Common.PushdownAutomaton, as: PA

  def entering(state, _to, _from, _type, _reason) do
    state
  end

  def on_event(state, event) do
    case event do
      :RESTART ->
        state
        |> PA.swap([:ap, :mode], :RESTART)

      :START ->
        state
        |> PA.swap([:ap, :mode], :RESTART)
       _ -> state
    end
  end

  def leaving(state, _to, _from, _type, _reason) do
    state
  end

  def frame(state) do
    state
  end
end
