defmodule Emulation.S5.GenAP.Modes.Interrupts.Time do
  alias Emulation.S5.AP.GenState, as: State
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.Device

  def entering(state, {_to, interrupt_id}, _from, type, _reason) do
    if type == :PUSHED do
      state
      |> PA.push([:ap, :exe], :DEFAULT)
      |> execute(interrupt_id)
    else
      state
    end
    |> Device.run()
  end

  def on_event(state, _event) do
    state
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

    {call, frequency, exp, _} =
      interrupts
      |> Enum.fetch!(interrupt_id)

    interrupts
    |> List.replace_at(interrupt_id, {
      call,
      frequency,
      exp,
      false
    })

    state |> State.set_time_interrupts(interrupts)
  end

  def execute(state, interrupt_id) do
    interrupts = state |> State.get_time_interrupts()
    {call, frequency, _, _} = interrupts |> Enum.fetch!(interrupt_id)

    {dt, unit} = frequency
    now = state |> State.now()
    exp = now + Emulations.Common.Time.convert(dt, unit, :microsecond)

    interrupts =
      interrupts
      |> List.replace_at(interrupt_id, {
        call,
        frequency,
        exp,
        true
      })

    state |> State.set_time_interrupts(interrupts)
  end
end
