defmodule Emulators.S5.GenAP do
  use Emulators.Device

  alias Emulators.S5.AP.GenState, as: State
  alias Emulators.PushdownAutomaton, as: PA
  alias Emulators.S5.Dispatcher

  alias Emulators.State, as: ES

  def create(start \\ true) do
    {:ok, device} = Emulators.Devices.start(__MODULE__)

    if start do
      Emulators.Devices.send(device, :START)
    end

    device
  end

  def start(_) do
    State.new()
  end

  def init(state) do
    state
    |> PA.push([:ap, :mode], :POWER_OFF)
  end

  def call(state, type, id) do
    state
    |> ES.push({:BLOCK_CALL, {type, id, :external}})
    |> ES.push({:BLOCK_RETURN, {type, id}})
  end

  def process_interrupts(state, dt) do
    {slice, unit} = dt
    
  end

  def process_event(state, event) do
    case event do
      {:BLOCK_CALL, {_, _, nature}} ->
        case nature do
          :internal ->
            state
            |> PA.push([:ap, :mode], :INTERPRET)

          :external ->
            state
            |> PA.push([:ap, :mode], :EXTERNAL)
        end

      {:BLOCK_RETURN, _} ->
        state |> PA.pop([:ap, :mode], :BLOCK_RETURN)

      msg ->
        state |> Emulators.S5.GenAP.Modes.process_event(msg)
    end
  end

  # Process internal events
  def process_events(state) do
    state |> ES.poll(&process_event/2)
  end

  # Process external messages 
  def process_message(state, msg, _from) do
    state =
      case msg do
        :POWER_ON ->
          state
          |> PA.swap([:ap, :mode], :POWER_ON)

        :SHUTDOWN ->
          state
          |> ES.push(:REQUEST_SHUTDOWN)

        :START ->
          state
          |> ES.push(:REQUEST_START)

        :DISPLAY_STATE ->
          IO.inspect(state)
          state

        {:WRITE_BLOCK, {type, id, body}} ->
          state |> State.write_block(type, id, body)

        _ ->
          state
      end

    {:pass, state}
  end

  def process_edges(state, old_state) do
    state
    |> State.set_edge(:RLO, State.get(state, :RLO) - State.get(old_state, :RLO))
  end

  def process_counters(state) do
    state
  end

  def process_timers(state, dt) do
    state
  end

  def frame(state, dt) do
    state
    |> Emulators.COM.dispatch(&process_message/3)
    |> process_events
    |> process_interrupts(dt)
    |> Emulators.S5.GenAP.Modes.frame()
    |> process_timers(dt)
    |> process_counters
    |> process_edges(state)
    |> Emulators.S5.GenAP.Modes.process_transitions
  end
end
