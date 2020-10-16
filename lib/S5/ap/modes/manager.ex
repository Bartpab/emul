defmodule Emulators.S5.GenAP.Modes do
  alias Emulators.PushdownAutomaton, as: PA

  @modes %{
    DEFAULT: Emulators.S5.GenAP.Modes.Default,
    POWER_OFF: Emulators.S5.GenAP.Modes.PowerOff,
    STOP: Emulators.S5.GenAP.Modes.Stop,
    RESTART: Emulators.S5.GenAP.Modes.Restart,
    RUN: Emulators.S5.GenAP.Modes.Run,
    CYCLE: Emulators.S5.GenAP.Modes.Cycle,
    INTERPRET: Emulators.S5.GenAP.Modes.Interpret,
    EXTERNAL: Emulators.S5.GenAP.Modes.External
  }

  def process_transition(state, {to, from, type, reason}) do
    state
    |> @modes[from].leaving(to, from, type, reason)
    |> @modes[from].entering(to, from, type, reason)
  end

  def process_transitions(state) do
    state
    |> PA.process_transitions([:ap, :mode], &process_transition/2)
  end

  def process_event(state, event) do
    current_mode = state |> PA.current([:ap, :mode])
    state
    |> @modes[current_mode].on_event(event)
  end

  def frame(state) do
    current_mode = state |> PA.current([:ap, :mode])
    state |> @modes[current_mode].frame()
  end
end
