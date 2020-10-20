defmodule Emulation.S5.AP.Bootstrap do
  alias Emulation.S5.AP

  def create() do
    device = AP.create()

    {:ok, blocks} = Emulation.S5.STL.load("codes/default.stl")

    AP.download_blocks(device, blocks)

    device
  end
end
