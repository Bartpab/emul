defmodule Emulators.S5.GenAP do
  use Emulators.Device

  alias Emulators.S5.AP.GenState
  alias Emulators.S5.Dispatcher

  alias Emulators.State, as: ES

  def start(_) do
    GenState.new()
  end

  def init(state) do
    state |> GenState.set_mode(:POWER_OFF)
  end

  def call(state, :OB, id) do
    state |> ES.push({:BLOCK_RETURN, {:OB, id}})
  end

  def call(state, :FB, id) do
    state |> ES.push({:BLOCK_RETURN, {:FB, id}})
  end

  def process_interrupt(state, interrupt) do
    case interrupt do
      {:CALL, {block_type, block_id}} -> state |> call(block_type, block_id)
    end
  end

  def process_internals(state) do
    state
    |> ES.poll(fn state, msg ->
      case msg do
        {:BLOCK_RETURN, {:OB, 1}} ->
          state |> GenState.set_mode(:RUN)

        {:BLOCK_RETURN, {:FB, 0}} ->
          state
          |> GenState.call(:FB, 0)
          |> GenState.set_mode(:RUN)

        {:BLOCK_RETURN, {:FB, 1}} ->
          state
          |> ES.interrupt({:FB, 1})
          |> GenState.call(:FB, 1)

        {:BLOCK_RETURN, {:OB, 20}} ->
          state |> GenState.call(:OB, 20)

        _ ->
          state
      end
    end)
  end

  def process_transition(state, transition) do
    case transition do
      {:POWER_OFF, _} ->
        state |> Device.set_mode(:IDLE)

      {:POWER_ON, _} ->
        state |> GenState.set_mode(:STOP)

      {:STOP, _} ->
        state |> Device.set_mode(:IDLE)

      {:RESTART, _} ->
        state = state |> Device.set_mode(:RUN)

        if GenState.has_block(state, :OB, 1) do
          state |> GenState.call(:OB, 1)
        else
          state |> GenState.call(:FB, 0)
        end

      {:RUN, _} ->
        if GenState.has_block(state, :OB, 20) do
          state |> GenState.call(:OB, 20)
        else
          state |> GenState.call(:FB, 1)
        end

      _ ->
        state
    end
  end

  def process_message(state, msg, _from) do
    state =
      case msg do
        :POWER_ON ->
          state |> GenState.set_mode(:POWER_ON)

        :POWER_OFF ->
          state |> GenState.set_mode(:POWER_OFF)

        :START ->
          state |> GenState.set_mode(:RESTART)

        :DISPLAY_STATE ->
          IO.inspect(state)
          state

        _ ->
          state
      end

    {:pass, state}
  end

  def frame(state) do
    state =
      state
      |> Emulators.COM.dispatch(&process_message/3)
      |> process_internals

    cond do
      # GenAP has a mode change
      GenState.has_mode_changed(state) ->
        state
        |> GenState.ack_mode()
        |> process_transition(GenState.mode_transition(state))

      # Called an interruption
      ES.has_interrupt(state) ->
        interrupt = ES.get_interrupt(state)

        state
        |> process_interrupt(interrupt)
        |> ES.clear_interrupt()

      # Regular business
      GenState.mode(state) in [:RUN, :RESTART] ->
        instr = state |> GenState.curr_instr()
        state |> Dispatcher.dispatch(Genstate, instr)
    end
  end
end
