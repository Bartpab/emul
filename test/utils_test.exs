defmodule EmulatorsTest do
  use ExUnit.Case

  test "adjust" do
    assert [0xDCBA] = Emulators.Utils.adjust([0xDC, 0xBA], 8, 16)
    assert [0xDC, 0xBA] = Emulators.Utils.adjust([0xDCBA], 16, 8)

    assert [0xDCBA1234] = Emulators.Utils.adjust([0xDC, 0xBA, 0x12, 0x34], 8, 32)
    assert [0xDC, 0xBA, 0x12, 0x34] = Emulators.Utils.adjust([0xDCBA1234], 32, 8)
  end
end
