defmodule Emulation.S5.AP.Bootstrap do
  alias Emulation.S5.AP

  def create(code \\ "codes/default.stl") do
    {:ok, blocks} = Emulation.S5.STL.load(code)
    IO.inspect(blocks)
    device = AP.create()
    AP.download_blocks(device, blocks)
    device
  end
end
