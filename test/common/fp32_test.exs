defmodule EmulationTest.FP32 do
  use ExUnit.Case
  use Bitwise

  alias Emulation.Common.FP32
  alias Emulation.Common.ShiftRegister, as: SR

  test "normalise base 2 1100.101" do
    fraction =
      SR.push_right(0, 1, 22)
      |> SR.push_right(0, 22)
      |> SR.push_right(1, 22)

    expected_fraction =
      SR.push_right(0, 1, 22)
      |> SR.push_right(0, 22)
      |> SR.push_right(1, 22)
      |> SR.push_right(0, 22)
      |> SR.push_right(0, 22)
      |> SR.push_right(1, 22)

    assert {{1, expected_fraction}, 3} = FP32.normalise({0b1100, fraction})
  end

  test "encode FP32 12.375 => 0x41460000" do
    assert 0x41460000 == FP32.encode(12.375)
  end

  test "decode FP32 0x41460000 => 12.375" do
    assert 12.375 = FP32.decode(0x41460000)
  end
end
