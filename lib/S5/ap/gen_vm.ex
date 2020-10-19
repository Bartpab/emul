defmodule Emulation.S5.GenAP do
  use Emulation.Device

  alias Emulation.S5.AP.GenState, as: State
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.S5.Dispatcher

  alias Emulation.Emulator.State, as: ES

  def create(start \\ true) do
    {:ok, device} = Emulation.Devices.start(__MODULE__)

    if start do
      Emulation.Devices.send(device, :START)
    end

    device
  end

  def start(state, _) do
    state |> State.new()
  end

  def init(state) do
    state
    |> PA.push([:ap, :mode], :POWER_OFF)
  end

  def call(state, type, id) do
    state
    |> ES.push({:BLOCK_RETURN, {type, id}})
  end

  def process_interrupts(state) do
    state
    # state |> Emulation.S5.GenAP.Interrupts.Time.process()
  end

  def process_event(state, event) do
    state
    |> Emulation.S5.Events.BlockEventProcessor.process_event(event)
    |> Emulation.S5.GenAP.Modes.process_event(event)
  end

  def process_edges(state, old_state) do
    state
    |> State.set_edge(:RLO, State.get(state, :RLO) - State.get(old_state, :RLO))
  end

  def process_timers(state, _dt) do
    state
  end

  def execute_instruction(state) do
    if PA.current(state, [:ap, :exe]) == :INTERPRET do
        state = state |> State.next_instr()
        instr = state |> State.current_instr()
  
        state
        |> Dispatcher.dispatch(State, instr)
      else
        state
      end  
    end

  def frame(state, {slice, unit}) do
    remaining = Emulations.Common.Time.convert(slice, unit, :microsecond)
    state |> run_frames(remaining)
  end

  def run_frames(state, remaining) do
    tick = state[:ap][:tick]
    slice = 50 # Slice per 50 microseconds

    if remaining < slice do
        state # Not enough time left... for a next time !
    else
        if state[:ap][:wait] > 0 do
            wait = state[:ap][:wait]
            state
            |> put_in([:ap, :wait], wait - slice)  
            |> run_frames(remaining - slice)         
        else
            state
            |> put_in([:ap, :wait], 0)
            |> Emulation.S5.GenAP.Modes.process_transitions
            |> dispatch_events(&process_event/2)
            |> process_interrupts
            |> Emulation.S5.GenAP.Modes.frame
            |> execute_instruction
            |> process_timers(slice)
            |> process_edges(state)
            |> put_in([:ap, :tick], tick + slice)
            |> run_frames(remaining - slice)
        end
    end
  end
end
