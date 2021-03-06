defmodule Emulation.Common.PushdownAutomaton do
  def new(state, addr) do
    state
    |> put_in(addr, %{
      stack: [:DEFAULT],
      transitions: [],
      valid: true
    })
  end

  def is_valid(state, addr) do
    get_in(state, addr ++ [:valid])
  end

  def get_transitions(state, addr) do
    state |> get_in(addr ++ [:transitions])
  end

  def set_transitions(state, addr, transitions) do
    state |> put_in(addr ++ [:transitions], transitions)
  end

  def process_transitions(state, addr, callback) do
    transitions = state |> get_transitions(addr)

    state
    |> set_transitions(addr, [])
    |> process_transitions(addr, callback, transitions)
    |> put_in(addr ++ [:valid], true)
  end

  def process_transitions(state, addr, callback, transitions) do
    case transitions do
      [head | tail] ->
        state
        |> callback.(head)
        |> process_transitions(addr, callback, tail)

      [] ->
        state
    end
  end

  def push_transition(state, addr, transition) do
    transitions =
      state
      |> get_transitions(addr)

    state
    |> put_in(addr ++ [:valid], false)
    |> set_transitions(addr, transitions ++ [transition])
  end

  def current(state, addr) do
    state
    |> get_stack(addr)
    |> Enum.fetch!(0)
  end

  def get_stack(state, addr) do
    state |> get_in(addr ++ [:stack])
  end

  def set_stack(state, addr, stack) do
    state
    |> put_in(addr ++ [:stack], stack)
  end

  def swap(state, addr, mode, reason \\ :NORMAL) do
    state
    |> push_transition(addr, {mode, state |> current(addr), :SWAPPED, reason})
    |> set_stack(
      addr,
      state
      |> get_stack(addr)
      |> List.replace_at(0, mode)
    )
  end

  def push(state, addr, mode, reason \\ :NORMAL) do
    stack =
      state
      |> get_stack(addr)

    stack = [mode] ++ stack

    state
    |> push_transition(addr, {mode, state |> current(addr), :PUSHED, reason})
    |> set_stack(addr, stack)
  end

  def pop(state, addr, reason \\ :NORMAL) do
    [from | tail] =
      state
      |> get_stack(addr)

    state
    |> push_transition(addr, {tail |> Enum.fetch!(0), from, :POPPED, reason})
    |> set_stack(addr, tail)
  end
end
