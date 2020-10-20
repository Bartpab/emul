defmodule Emulation.S5.AP.Bootstrap do
  alias Emulation.S5.AP

  def create() do
    device = AP.create()

    AP.download_blocks(device, [
      {:OB, 1,
       [
         {:BE, :no_operand, []}
       ]},
      {:OB, 11,
       [
         {:BE, :no_operand, []}
       ]}
    ])

    device
  end
end
