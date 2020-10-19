defmodule Emulation.Emulator do
  defmacro __using__(_) do
    quote do
      def push_event(state, msg) do
        state |> Emulation.Emulator.State.push(msg)
      end

      def dispatch_events(state, callback) do
        state |> Emulation.Emulator.State.poll(callback)
      end
    end
  end
end
