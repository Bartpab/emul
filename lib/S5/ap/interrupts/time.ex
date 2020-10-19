defmodule Emulation.S5.GenAP.Interrupts.Time do
  alias Emulation.S5.AP.GenState, as: State
  alias Emulation.Common.PushdownAutomaton, as: PA

  def get_expired(state) do
    timers = state |> State.get_time_interrupts()
    get_expired(state[:ap][:tick], timers, 0)
  end

  def get_expired(now, timers, index) do
    case timers do
      [{_, _, exp, _} | tail] ->
        case Emulations.Common.Time.compare(exp, now) do
          :gt -> []
          :lt -> [index]
          :eq -> [index]
        end ++ get_expired(now, tail, index)

      [] ->
        []
    end
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
            raise "Time interrupt collision for #{type} n°#{id}."

          priority < interrupt_id ->
            state
            |> PA.push([:ap, :mode], {:TIME, interrupt_id})

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
        [head | _] -> execute(state, head)
        [] -> state
      end
    else
      state
    end
  end
end
