defmodule Emulation.Emulator.State do
  def new() do
    %{
      emulator: %{
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

    state
    |> put_in([:emulator, :messages], [])
    |> poll(callback, messages)
  end

  def poll(state, callback, messages) do
    case messages do
      [msg | tail] ->
        state
        |> callback.(msg)
        |> poll(callback, tail)

      [] ->
        state
    end
  end
end
