defmodule Emulators.Device do
    def process(state, msg, from) do
        case msg do
            {:GET, :STATE} -> 
                state = state |> Emulators.COM.send(from, {:STATE, state})
                {:pass, state}
            :PING ->
                state = state |> Emulators.COM.send(from, :PONG)
                {:pass, state}              
            _ -> 
                {:keep, state}
        end
    end

    defmacro __using__(_) do
        quote do
            def child_spec({id, opts}) do
                %{
                    id: id,
                    start: {__MODULE__, :start_link, [id, opts]}
                }
            end
        
            def start_link(id, opts) do
                pid = spawn fn -> 
                    start(opts) 
                        |> Map.merge(%{device: %{id: id}})
                        |> Map.merge(Emulators.COM.new())        
                        |> loop() 
                end
                Emulators.Devices.bind(pid, id)
                {:ok, pid}
            end
            
            def snapshot(state) do
                Emulators.StateStash.save(state)
                state
            end

            def loop(state) do
                state = state 
                    |> Emulators.COM.poll
                    |> Emulators.COM.dispatch(&Emulators.Device.process/3)
                    |> frame
                    |> Emulators.COM.commit
                    |> Map.put(:last_tick, NaiveDateTime.utc_now)
                    |> snapshot
                    |> loop
            end
        end
    end
end


defmodule Emulators.S5.AP do
    use Emulators.Device

    alias Emulators.S5.AP.State
    alias Emulators.S5.AP.Firmware

    def start(_) do
        State.new()
    end

    def frame(state) do
        state |> Firmware.frame
    end
end

defmodule Emulators.S5.AS do
    use Emulators.Device
    use Emulators.COM

    def start(_) do
        %{}
    end

    
    def frame(state) do
        state
    end
end