defmodule Emulators.S5.GenAP do
  use Emulators.Device

  alias Emulators.S5.AP.GenState
  alias Emulators.S5.Dispatcher

  alias Emulators.State, as: ES

  def create(start \\ true) do
    {:ok, device} = Emulators.Devices.start(__MODULE__)
    
    if start do
        Emulators.Devices.send(device, :POWER_ON)
        Emulators.Devices.send(device, :START)
    end

    device
  end

  def start(_) do
    GenState.new()
  end

  def init(state) do
    state |> GenState.set_state(:POWER_OFF)
  end

  def call(state, type, id) do
    state
    |> ES.push({:BLOCK_CALL, {type, id, :external}})
    |> ES.push({:BLOCK_RETURN, {type, id}})
  end

  def do_restart(state) do
    state 
    |> GenState.set_state(:RUN)
  end

  def do_cycle(state) do
    if state |> GenState.has_block(:OB, 1) do
        state |> GenState.call(:OB, 1)
    else
        state
    end
  end

  def process_interrupt(state, interrupt) do
    case interrupt do
      {:CALL, {type, id}} -> state |> call(type, id)
    end
  end

  def process_internals(state) do
    state
    |> ES.poll(fn state, msg ->
      case msg do
        {:BLOCK_CALL, {_, _, nature}} ->
          case nature do
            :internal ->
              state
              |> GenState.push_state(:RUN_INTERNAL)

            :external ->
              state
              |> GenState.push_state(:RUN_EXTERNAL)
          end

        {:BLOCK_RETURN, _} ->
          state
          |> GenState.pop_state()
          |> GenState.pop_state()
      end
    end)
  end

  def process_transition(state, {:POWER_OFF, :DEFAULT, :SWAPPED}) do
    state |> Device.set_mode(:IDLE)
  end

  def process_transition(state, {:POWER_ON, :POWER_OFF, :SWAPPED}) do
    state |> GenState.set_state(:STOP)
  end

  def process_transition(state, {:STOP, _, _}) do
    state |> Device.set_mode(:IDLE)
  end

  def process_transition(state, {:RESTART, :STOP, :SWAPPED}) do
    state
    |> do_restart
    |> Device.set_mode(:RUN)
  end

  def process_transition(state, {:START, :RESTART, :SWAPPED}) do
    state
    |> Device.set_mode(:RUN)
    |> GenState.push_state(:CYCLE)
  end

  def process_transition(state, {:CYCLE, from, _})
      when from in [:RUN, :RUN_INTERNAL, :RUN_EXTERNAL] do
    state
    |> do_cycle()
  end

  def process_transition(state, {new, old, reason}) do
    raise "Forbidden transition #{old} -> #{new} [#{reason}]."
  end

  def process_message(state, msg, _from) do
    state =
      case msg do
        :POWER_ON ->
          state
          |> GenState.set_state(:POWER_ON)

        :POWER_OFF ->
          state
          |> GenState.set_state(:STOP)
          |> GenState.set_state(:POWER_OFF)

        :START ->
          state
          |> GenState.set_state(:STOP)
          |> GenState.set_state(:RESTART)

        :DISPLAY_STATE ->
          IO.inspect(state)
          state
        
        {:WRITE_BLOCK, {type, id, body}} -> 
            state |> GenState.write_block(type, id, body)
        _ -> state
      end

    {:pass, state}
  end

  def process_edges(state, old_state) do
    state
    |> GenState.set_edge(:RLO, GenState.get(state, :RLO) - GenState.get(old_state, :RLO))
  end

  def process_counters(state) do
    state
  end

  def process_timers(state) do
    state
  end

  def process_transitions(state) do
    transitions = GenState.get_transitions(state)
    state
    |> process_transitions(transitions)
    |> GenState.clear_transitions
  end

  def process_transitions(state, transitions) do
    case transitions do
        [head | tail] ->
            state
            |> process_transition(head)
            |> process_transitions(tail)
        [] -> state
    end
  end

  def frame(state) do
    prev_state = state

    state =
      state
      |> Emulators.COM.dispatch(&process_message/3)
      |> process_internals

    cond do
      # Called an interruption
      ES.has_interrupt(state) ->
        interrupt = ES.get_interrupt(state)

        state =
          state
          |> process_interrupt(interrupt)
          |> ES.clear_interrupt()

      # Regular business
      GenState.current_state(state) == :RUN_INTERNAL ->
        state = state |> GenState.next_instr()
        instr = state |> GenState.current_instr()

        state =
          state
          |> Dispatcher.dispatch(Genstate, instr)

      true ->
        state
    end

    state
    |> process_timers
    |> process_counters
    |> process_edges(state)
    |> process_transitions
  end
end
