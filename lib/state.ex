defmodule Emulators.State do
  def new() do
    %{
      emulator: %{
        interrupt: nil,
        messages: []
      }
    }
  end

  def push(state, msg) do
    messages = get_in(state, [:emulator, :messages]) ++ [msg]
    put_in(state, [:emulator, :messages], messages)
  end

  def poll(state, callback) do
    messages = get_in(state, [:emulator, :messages])
    state |> poll(callback, messages)
  end

  def poll(state, callback, messages) do
    case messages do
      [msg | tail] ->
        state
        |> callback.(msg)
        |> poll(callback, tail)

      [] ->
        state |> put_in([:emulator, :messages], [])
    end
  end

  def has_interrupt(state) do
    state[:emulator][:interrupt] != nil
  end

  def get_interrupt(state) do
    get_in(state, [:emulator, :interrupt])
  end

  def interrupt(state, interrupt) do
    put_in(state, [:emulator, :interrupt], interrupt)
  end

  def clear_interrupt(state) do
    state |> interrupt(nil)
  end
end
