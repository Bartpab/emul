defmodule Emulators.Device do
    def set_mode(state, mode) do
        put_in(state, [:device, :mode], mode)
    end

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
            use Task, restart: :temporary

            def start_link({id, opts} = arg) do
                Task.start_link(__MODULE__, :run, [arg])
              end

            def run({id, opts}) do
                Emulators.Devices.bind(self(), id)
                
                start(opts) 
                    |> Map.merge(%{device: %{id: id, mode: :RUN}})
                    |> Map.merge(Emulators.COM.new())      
                    |> init  
                    |> loop 
            end
            
            def snapshot(state) do
                spawn fn -> Emulators.StateStash.save(state) end
                state
            end

            def loop(state) do
                state = state 
                    |> Emulators.COM.poll([], state[:device][:mode] == :IDLE)
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

    def init(state) do
        state |> Firmware.init
    end

    def frame(state) do
        state |> Firmware.frame
    end
end
