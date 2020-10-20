defmodule Emulation.S5.AP.Modes.Interrupts.Time do
  alias Emulation.S5.AP.State, as: State
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.Emulator.State, as: ES
  alias Emulation.Device

  def entering(state, {_to, interrupt_id}, _from, type, _reason) do
    if type == :PUSHED do
      state
      |> PA.push([:ap, :exe], :DEFAULT)
      |> execute(interrupt_id)
    else
      state
    end
  end

  def on_event(state, event) do
    case event do
      :RESTART ->
        state
        |> ES.push(event)
        |> PA.pop([:ap, :mode])

      :STOP ->
        state
        |> ES.push(event)
        |> PA.pop([:ap, :mode])

      _ ->
        state
    end
  end

  def leaving(state, _to, {_from, interrupt_id}, type, _reason) do
    if type == :POPPED do
      state
      |> PA.pop([:ap, :exe])
      |> clear_flag(interrupt_id)
    else
      state
    end
  end

  def frame(state) do
    # If we returned from execution (DEFAULT state), that means we can pop the mode frame
    if state |> PA.current([:ap, :exe]) == :DEFAULT do
      state |> PA.pop([:ap, :mode])
    else
      state
    end
  end

  def clear_flag(state, interrupt_id) do
    interrupts = state |> State.get_time_interrupts()

    {call, frequency, exp, enabled, _executed} =
      interrupts
      |> Enum.fetch!(interrupt_id)

    interrupts
    |> List.replace_at(interrupt_id, {
      call,
      frequency,
      exp,
      enabled,
      false
    })

    state |> State.set_time_interrupts(interrupts)
  end

  def execute(state, interrupt_id) do
    interrupts = state |> State.get_time_interrupts()
    {call, frequency, _exp, enabled, _executed} = interrupts |> Enum.fetch!(interrupt_id)

    {dt, unit} = frequency
    now = state |> State.now()
    exp = now + Emulations.Common.Time.convert(dt, unit, :microsecond)

    interrupts =
      interrupts
      |> List.replace_at(interrupt_id, {
        call,
        frequency,
        exp,
        enabled,
        true
      })

    {type, id} = call

    state
    |> State.call(type, id)
    |> State.set_time_interrupts(interrupts)
  end
end
