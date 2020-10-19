defmodule Emulation.S5.GenAP.Modes do
  alias Emulation.Common.PushdownAutomaton, as: PA

  @modes %{
    DEFAULT: Emulation.S5.GenAP.Modes.Default,
    POWER_OFF: Emulation.S5.GenAP.Modes.PowerOff,
    STOP: Emulation.S5.GenAP.Modes.Stop,
    RESTART: Emulation.S5.GenAP.Modes.Restart,
    RUN: Emulation.S5.GenAP.Modes.Run,
    CYCLE: Emulation.S5.GenAP.Modes.Cycle,
    TIME: Emulation.S5.GenAP.Modes.Interrupts.Time
  }

  def process_transition(state, {to, from, type, reason}) do
    class_from =
      case from do
        {state, _} -> state
        _ -> from
      end

    state
    |> @modes[class_from].leaving(to, from, type, reason)
    |> @modes[class_from].entering(to, from, type, reason)
  end

  def process_transitions(state) do
    state
    |> PA.process_transitions([:ap, :mode], &process_transition/2)
  end

  def process_event(state, event) do
    current_mode = state |> PA.current([:ap, :mode])

    current_class =
      case current_mode do
        {state, _} -> state
        other -> other
      end

    state
    |> @modes[current_class].on_event(event)
  end

  def frame(state) do
    if state |> PA.is_valid([:ap, :mode]) do
        current_mode = state |> PA.current([:ap, :mode])

        current_class =
        case current_mode do
            {state, _} -> state
            other -> other
        end

        state |> @modes[current_class].frame()
    else
        state
    end
  end
end
