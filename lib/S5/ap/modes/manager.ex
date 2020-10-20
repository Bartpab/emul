defmodule Emulation.S5.AP.Modes do
  alias Emulation.Common.PushdownAutomaton, as: PA

  @modes %{
    DEFAULT: Emulation.S5.AP.Modes.Default,
    POWER_OFF: Emulation.S5.AP.Modes.PowerOff,
    STOP: Emulation.S5.AP.Modes.Stop,
    RESTART: Emulation.S5.AP.Modes.Restart,
    RUN: Emulation.S5.AP.Modes.Run,
    CYCLE: Emulation.S5.AP.Modes.Cycle,
    TIME: Emulation.S5.AP.Modes.Interrupts.Time
  }

  def process_transition(state, {to, from, type, reason}) do
    IO.inspect(to)

    class_from =
      case from do
        {state, _} -> state
        _ -> from
      end

    class_to =
      case to do
        {state, _} -> state
        _ -> to
      end

    state
    |> @modes[class_from].leaving(to, from, type, reason)
    |> @modes[class_to].entering(to, from, type, reason)
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
