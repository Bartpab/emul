defmodule Emulation.S5.AP.Interrupts.Time do
  alias Emulation.S5.AP.State, as: State
  alias Emulation.Common.PushdownAutomaton, as: PA

  def get_expired(state) do
    timers = state |> State.get_time_interrupts()
    get_expired(state |> State.now(), timers, 0)
  end

  def get_expired(now, timers, index) do
    case timers do
      [{_, _, exp, enabled, _executed} | tail] ->
        if enabled do
          case Emulations.Common.Time.compare(exp, now) do
            :gt -> []
            :lt -> [index]
            :eq -> [index]
          end
        else
          []
        end ++
          get_expired(now, tail, index + 1)

      [] ->
        []
    end
  end

  def map_interrupts(state, timers) do
    case timers do
      [{call, time, exp, _enabled, _executed} | tail] ->
        {type, id} = call
        enabled = State.has_block(state, type, id)
        [{call, time, exp, enabled, false}] ++ map_interrupts(state, tail)

      [] ->
        []
    end
  end

  def restart(state) do
    timers = state |> State.get_time_interrupts()
    state |> State.set_time_interrupts(map_interrupts(state, timers))
  end

  def execute(state, interrupt_id) do
    {{type, id}, _, _, exe} =
      state
      |> State.get_time_interrupts()
      |> Enum.fetch!(interrupt_id)

    case PA.current(state, [:ap, :mode]) do
      {:TIME, priority} ->
        cond do
          exe ->
            raise "Time interrupt collision for #{type} #{id}."

          priority < interrupt_id ->
            state |> PA.push([:ap, :mode], {:TIME, interrupt_id})

          true ->
            state
        end

      _ ->
        state |> PA.push([:ap, :mode], {:TIME, interrupt_id})
    end
  end

  def process(state) do
    if State.get_flag(state, :enable_interrupts) do
      expired = get_expired(state)

      case expired do
        [head | _] -> state |> execute(head)
        [] -> state
      end
    else
      state
    end
  end
end
