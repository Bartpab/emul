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
            [get_in(state, [:COM, :sent]) | [{to, {msg, self()}}]]
        )
    end
    
    def poll(state, callback) do
        {state, left} = poll(state, callback, state[:COM][:recv], [])
        state |> put_in([:COM, :recv], left) 
    end

    def clear_recv(state) do
        state |> put_in([:COM, :recv], []) 
    end

    def send_messages(state) do
        state 
            |> get_in([:COM, :sent])
            |> Enum.each(fn {to, msg} -> send(to, msg) end)
            
        state |> put_in([:COM, :sent], [])
    end

    def poll(state, callback, messages, left) do
        case messages do
            [{msg, from} | tail] ->
                {result, state} = callback.(state, msg, from)
                case result do
                    :keep -> poll(state, callback, tail, [left | {msg, from}])
                    _ -> poll(state, callback, tail, left)
                end
            _ ->
                {state, left}
        end        
    end


end