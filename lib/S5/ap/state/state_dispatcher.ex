defmodule Emulation.S5.AP.StateDispatcher do
  def dispatch(state) do
    type = state[:ap][:type]

    case type do
      :GENERIC -> Emulation.S5.AP.GenericState
    end
  end

  # Common related (do not implement)
  def now(state) do
    dispatch(state).now(state)
  end

  def registers(state) do
    dispatch(state).registers(state)
  end

  def set_registers(state, registers) do
    dispatch(state).set_registers(state, registers)
  end

  def set_edge(state, edge, value) do
    dispatch(state).set_edge(state, edge, value)
  end

  def get_edge(state, edge) do
    dispatch(state).get_edge(state, edge)
  end

  # State specialisation (do implement)
  # Flag related
  def set_flag(state, type, value) do
    dispatch(state).set_flag(state, type, value)
  end

  def get_flag(state, type) do
    dispatch(state).get_flag(state, type)
  end

  # Interrupt related
  def get_time_interrupts(state) do
    dispatch(state).get_time_interrupts(state)
  end

  def set_time_interrupts(state, interrupts) do
    dispatch(state).set_time_interrupts(state, interrupts)
  end

  # Timer-related
  def set_timer_last_tick(state, timer_id, tick) do
    dispatch(state).set_timer_last_tick(state, timer_id, tick)
  end

  def get_timer_last_tick(state, timer_id) do
    dispatch(state).get_timer_last_tick(state, timer_id)
  end

  # Instructions related
  def current_instr(state) do
    dispatch(state).current_instr(state)
  end

  def next_instr(state) do
    dispatch(state).next_instr(state)
  end

  # Block-related functions
  def write_block(state, type, id, instrs) do
    dispatch(state).write_block(state, type, id, instrs)
  end

  def get_block(state, type, id) do
    dispatch(state).get_block(state, type, id)
  end

  def has_block(state, type, id) do
    dispatch(state).has_block(state, type, id)
  end

  def push_bstack(state, {_offset, _sac, _dba, _dbl} = args) do
    dispatch(state).push_bstack(state, args)
  end

  def pop_bstack(state) do
    dispatch(state).pop_bstack(state)
  end

  def open(state, id) do
    dispatch(state).open(state, id)
  end

  # Block call/return
  def call(state, type, id) do
    dispatch(state).call(state, type, id)
  end

  def return(state) do
    dispatch(state).return(state)
  end

  # Memory related
  def write_area!(state, type, content) do
    dispatch(state).write_area!(state, type, content)
  end

  def take_area!(state, type) do
    dispatch(state).take_area!(state, type)
  end

  def set(state, operand, args, values) do
    dispatch(state).set(state, operand, args, values)
  end

  def get(state, operand, args) do
    dispatch(state).get(state, operand, args)
  end

  # Register related
  def get(state, register) do
    dispatch(state).get(state, register)
  end

  def set(state, register, value) do
    dispatch(state).set(state, register, value)
  end
end
