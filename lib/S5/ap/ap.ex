defmodule Emulation.S5.AP do
  use Emulation.Device

  alias Emulation.S5.AP.StateDispatcher, as: State
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.S5.Dispatcher

  alias Emulation.Emulator.State, as: ES

  # API
  def create(start \\ true) do
    {:ok, device} = Emulation.Devices.start(__MODULE__)

    if start do
      Emulation.Devices.send(device, :START)
    end

    device
  end

  def shutdown(device) do
    Emulation.Devices.shutdown(device)
  end

  def stop(device) do
    Emulation.Devices.send(device, :STOP)
  end

  def start(device) do
    Emulation.Devices.send(device, :START)
  end

  def download_blocks(device, blocks) do
    stop(device)
    write_blocks(device, blocks)
    start(device)
  end

  defp write_blocks(device, blocks) do
    case blocks do
      [head | tail] ->
        write_block(device, head)
        write_blocks(device, tail)

      [] ->
        :ok
    end
  end

  defp write_block(device, block) do
    Emulation.Devices.send(device, {:WRITE_BLOCK, block})
  end

  # Internals
  def create_device(state, _) do
    state |> Emulation.S5.AP.GenericState.new()
  end

  def init_device(state) do
    state
    |> PA.push([:ap, :mode], :POWER_OFF)
  end

  def call(state, type, id) do
    state
    |> ES.push({:BLOCK_RETURN, {type, id}})
  end

  def process_interrupts(state) do
    state |> Emulation.S5.AP.Interrupts.Time.process()
  end

  def process_event(state, event) do
    state
    |> Emulation.S5.Events.BlockEventProcessor.process_event(event)
    |> Emulation.S5.AP.Modes.process_event(event)
  end

  def process_edges(state, old_state) do
    state |> Emulation.S5.AP.Services.Edges.process(old_state)
  end

  def process_timers(state, _dt) do
    state |> Emulation.S5.AP.Services.Timers.process()
  end

  def execute_instruction(state) do
    if PA.is_valid(state, [:ap, :mode]) do
      if PA.current(state, [:ap, :exe]) == :INTERPRET do
        state = state |> State.next_instr()
        instr = state |> State.current_instr()

        state
        |> Dispatcher.dispatch(State, instr)
      else
        state
      end
    else
      state
    end
  end

  def frame(state, {slice, unit}) do
    remaining = Emulations.Common.Time.convert(slice, unit, :microsecond)
    state |> run_frames(remaining)
  end

  def run_frames(state, remaining) do
    tick = state |> State.now()
    # Slice per 50 microseconds
    slice = 100

    if remaining < slice do
      # Not enough time left... for a next time !
      state
    else
      if state[:ap][:wait] > 0 do
        wait = state[:ap][:wait]

        state
        |> put_in([:ap, :wait], wait - slice)
        |> run_frames(remaining - slice)
      else
        state
        |> put_in([:ap, :wait], 0)
        |> PA.set_transitions([:ap, :exe], [])
        |> Emulation.S5.AP.Modes.process_transitions()
        |> dispatch_events(&process_event/2)
        |> process_interrupts
        |> Emulation.S5.AP.Modes.frame()
        |> execute_instruction
        |> process_timers(slice)
        |> process_edges(state)
        |> put_in([:ap, :tick], tick + slice)
        |> run_frames(remaining - slice)
      end
    end
  end
end
