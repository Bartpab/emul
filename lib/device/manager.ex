defmodule Emulation.Devices do
  import Kernel, except: [send: 2]
  use GenServer

  alias Emulation.DeviceSupervisor

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_) do
    {:ok, {0, %{}, %{}}}
  end

  def start(device, opts \\ []) do
    device_id = String.to_atom("device_#{new()}")

    {:ok, pid} =
      DynamicSupervisor.start_child(
        DeviceSupervisor,
        {device, {device_id, opts}}
      )

    Process.register(pid, device_id)
    {:ok, device_id}
  end

  defp new() do
    GenServer.call(__MODULE__, :new)
  end

  def all() do
    GenServer.call(__MODULE__, {:get, :all})
  end

  def display_state(device) do
    send(device, :DISPLAY_STATE)
  end

  def bind(pid, id) do
    GenServer.cast(__MODULE__, {:bind, pid, id})
  end

  def send(id, msg, from \\ self()) do
    Kernel.send(id, {msg, from})
    :ok
  end

  @impl true
  def handle_cast({:bind, pid, id}, {counter, register, reverse}) do
    register =
      register
      |> Map.put(id, pid)

    reverse =
      reverse
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
