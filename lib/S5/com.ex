defmodule Emulators.COM do
    defmacro __using__(_) do
        quote do
            def send(state, msg, to) do
                state |> Emulators.COM.send(state, msg, to)
            end
            def poll(state, callback) do
                state |> Emulators.COM.poll(callback)
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
    
    def poll(state, messages \\ []) do
        receive do
            msg ->
                state |> poll(messages ++ [msg])
        after
            0 -> state
                |> put_in([:COM, :recv], messages)
        end
    end

    def commit(state) do
        state 
            |> get_in([:COM, :sent])
            |> Enum.each(
                fn {to, msg} -> 
                    if is_pid(to) do
                        send(to, {msg, state[:device][:id]}) 
                    else
                        Emulators.Devices.send_to_device(to, msg, state[:device][:id])
                    end
                end
            )
            
        state |> put_in([:COM, :sent], [])
    end
    
    def dispatch(state, callback) do
        state |> dispatch(callback, get_in(state, [:COM, :recv]))
    end
    
    def dispatch(state, callback, messages, keep \\ []) do
        case messages do
            [msg | tail] ->
                {payload, from} = msg
                {result, state} = callback.(state, payload, from)
                case result do
                    :keep -> dispatch(state, callback, tail, keep ++ [{payload, from}])
                    :pass -> dispatch(state, callback, tail, keep)
                end
            [] ->
                state 
                    |> put_in([:COM, :recv], keep)
        end        
    end
end