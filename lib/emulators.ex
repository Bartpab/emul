defmodule Emulators.DeviceSupervisor do
    use DynamicSupervisor

    def start_link(init_arg) do
        DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
    end
    
    @impl true
    def init(_init_arg) do
        DynamicSupervisor.init(strategy: :one_for_one)
    end

    def count_devices() do
        DynamicSupervisor.count_children(__MODULE__)
    end
end

defmodule Emulators.Devices do
    use GenServer

    alias Emulators.DeviceSupervisor

    def start_link(args) do
        GenServer.start_link(__MODULE__, args, name: __MODULE__)
    end

    @impl true
    def init(_) do
        {:ok, {0, %{}, %{}}}
    end

    def start(device, opts \\ []) do
        device_id = String.to_atom("device_#{new()}")
        
        {:ok, pid} = DynamicSupervisor.start_child(
            DeviceSupervisor, {device, {device_id, opts}}
        )

        {:ok, device_id}
    end

    defp new() do
        GenServer.call(__MODULE__, :new)
    end

    def all() do
        GenServer.call(__MODULE__, {:get, :all})
    end

    def bind(pid, id) do
        GenServer.cast(__MODULE__, {:bind, pid, id})
    end

    def send_to_device(id, msg, from \\ self()) do
        pid = GenServer.call(__MODULE__, {:get, :pid, id})
        send(pid, {msg, from})
    end
    
    @impl true
    def handle_cast({:bind, pid, id}, {counter, register, reverse}) do
        Process.register(pid, id)

        register = register 
            |> Map.put(id, pid)
        
        reverse = reverse
            |> Map.put(pid, id)
            
        {:noreply, {counter, register, reverse}}
    end

    @impl true
    def handle_call(:new, _from, {counter, register, reverse}) do
        counter = counter + 1
        {:reply, counter, {counter, register, reverse}}
    end

    @impl true
    def handle_call({:get, :all}, _from, {counter, register, reverse}) do
        {:reply, register, {counter, register, reverse}}
    end

    @impl true
    def handle_call({:get, :pid, id}, _from, {counter, register, reverse}) do
        {:reply, register |> Map.fetch!(id), {counter, register, reverse}}
    end
end

defmodule Emulators.StateStash do
    use GenServer

    def start_link(args) do
        GenServer.start_link(__MODULE__, args, name: __MODULE__)
    end
    
    def save(state) do
        GenServer.cast(__MODULE__, {:save, state[:device][:id], state})
    end

    def get(id) do
        GenServer.call(__MODULE__, {:get, id})
    end

    def all() do
        GenServer.call(__MODULE__, {:get, :all})
    end

    @impl true
    def init(_init_arg) do
        {:ok, %{}}
    end
    
    @impl true
    def handle_cast({:save, id, device_state}, state) do
        {:noreply, state |> Map.put(id, device_state)}
    end

    @impl true
    def handle_call({:get, id}, _from, state) do
        case id do
            :all -> {:reply, state, state}
            id -> {:reply, state |> Map.fetch(id), state}
        end
    end
end

defmodule Emulators.Application do
    use Application
    def start(_, _) do
        
        children = [
            Emulators.StateStash,
            Emulators.Devices,
            Emulators.DeviceSupervisor
        ]

        Supervisor.start_link(children, strategy: :one_for_one)
    end
end
