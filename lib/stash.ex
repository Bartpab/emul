defmodule Emulation.StateStash do
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
