defmodule Emulation.COM do
  defmacro __using__(_) do
    quote do
      def send(state, msg, to) do
        state |> Emulation.COM.send(msg, to)
      end

      def dispatch_messages(state, callback) do
        state |> Emulation.COM.dispatch(callback)
      end

      def poll_messages(state, callback) do
        state |> Emulation.COM.poll(callback)
      end

      def commit_messages(state) do
        state |> Emulation.COM.commit()
      end
    end
  end

  def new() do
    %{COM: %{recv: [], sent: []}}
  end

  def send(state, msg, to) do
    put_in(
      state,
      [:COM, :sent],
      get_in(state, [:COM, :sent]) ++ [{msg, to}]
    )
  end

  def poll(state, timeout \\ 0) do
    state |> poll_msg([], timeout)
  end

  def poll_msg(state, messages \\ [], timeout \\ 0) do
    receive do
      msg ->
        state |> poll_msg(messages ++ [msg])
    after
      timeout -> state |> put_in([:COM, :recv], messages)
    end
  end

  def commit(state) do
    state
    |> get_in([:COM, :sent])
    |> Enum.each(fn {to, msg} ->
      if is_pid(to) do
        send(to, {msg, state[:device][:id]})
      else
        Emulation.Devices.send(to, msg, state[:device][:id])
      end
    end)

    state |> put_in([:COM, :sent], [])
  end

  def dispatch(state, callback) do
    state |> dispatch(callback, get_in(state, [:COM, :recv]))
  end

  def dispatch(state, callback, messages, keep \\ []) do
    case messages do
      [msg | tail] ->
        case msg do
          {:system, {from, _}, :get_status} ->
            send(from, state)

          {payload, from} ->
            {result, state} = callback.(state, payload, from)

            case result do
              :keep -> dispatch(state, callback, tail, keep ++ [{payload, from}])
              :pass -> dispatch(state, callback, tail, keep)
            end
        end

      [] ->
        state
        |> put_in([:COM, :recv], keep)
    end
  end
end
