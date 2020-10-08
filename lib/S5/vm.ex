defmodule Emulators.Supervisor do
    use Emulators.COM

    def new() do
        %{
            supervisor: %{
                devices: []
            }
        }
    end

    def supervise(state, {id, pid}) do
        devices = get_in(state, [:supervisor, :devices])
        put_in(
            state, [:supervisor, :devices], [devices | [%{
                id: id,
                pid: pid, 
                exp: NaiveDateTime.utc_now() |> NaiveDateTime.add(1, :second)
                state: :IDLE,
                attempts: 0
            }]
        ])       
    end

    def update(state, device) do
        now = NaiveDateTime.utc_now()

        case NaiveDateTime.compare(now, device[:exp]) do
            :lt ->
                case device[:state] do
                    :ALIVE ->
                        device = device |> Map.put(:state, :ALIVE?)
                            |> Map.put(:exp, NaiveDateTime.utc_now() |> NaiveDateTime.add(5, :second))
                        state = state |> 
                end
            _ -> {state, device}
        end
    end

    def manage(state, devices) do
        case devices do
            [device | devices] ->
                {state, device} = update(state, device)
                {state, tail} = manage(state, devices)
                {state, [[device] | tail]}
            [] -> {state, []}
        end
    end

    def frame(state) do
        state |> manage
    end
end

defmodule Emulators.Device do
    def process(state, msg, from) do
        case msg do
            {:GET, :STATE} -> 
                state = state |> Emulators.COM.send(from, {:STATE, state})
                {:pass, state}
            :PING ->
                state = state |> Emulators.COM.send(from, :PONG)
                {:pass, state}              
            _ -> {:keep, state}
        end
    end

    defmacro __using__(_) do
        quote do
            def new(id \\ UUID.uuid4(), opts \\ nil) do
                pid = spawn fn -> 
                    :ets.new(id, [:set, :named_table, :protected])
                    start(opts) 
                        |> Map.merge(Emulators.COM.new())        
                        |> loop() 
                end
                {id, pid}
            end
            
            def relaunch(id) do
                :ets.lookup(id, :state)
            end

            def loop(state) do
                loop(
                    :ets.insert(self(), {:state, state})
                    state 
                        |> Emulators.COM.poll(&Emulators.Device.process/3)
                        |> frame
                        |> Emulators.COM.clear_recv
                        |> Emulators.COM.send_messages
                )
            end
        end
    end
end


defmodule Emulators.S5.AP do
    use Emulators.Device

    alias Emulators.S5.AP.State
    alias Emulators.S5.AP.Firmware

    def start() do
        State.new()
    end

    def restart(state) do
        state
    end

    def frame(state) do
        state |> Firmware.frame
    end
end

defmodule Emulators.S5.AS do
    use Emulators.Supervisor
    use Emulators.Device
    use Emulators.COM

    alias Emulators.S5.AP

    def start(id \\ nil) do
        state = %{
            :cluster => cluster, 
            :id => id,
            :AP => []
        }  | Map.merge!(Supervisor.new())
    end

    def create(state, :AP) do
        aps = [get_in(state, [:AP]) | [AP.new()]]
        put_in(state, [:AP], aps)
    end

    def process(state, message, _from) do
        case message do
            {:AS, :CREATE, :AP}-> 
                {:pass, state}
        end
    end
    
    def frame(state) do
        state = state |> poll(&process/3)
        self() |> :ets.insert({:state, state})
        state     
    end
end

defmodule Emulators.Cluster do
    use Emulators.Supervisor
    use Emulators.Device

    def start(_) do
        %{}
    end

    def process(state, message, from) do
        case message do
            {:CREATE, :AS} ->
                state
                |> Supervisor.register(AS.new())
        end
        {:pass, state}
    end
    
    def frame(state) do
        state
            |> Supervisor.frame 
            |> poll(&process/3)
    end

end