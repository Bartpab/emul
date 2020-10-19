defmodule Emulation.Application do
  use Application

  def start(_, _) do
    children = [
      Emulation.StateStash,
      Emulation.Devices,
      Emulation.DeviceSupervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
