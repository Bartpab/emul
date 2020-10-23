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

    assert {{1, ^expected_fraction}, 3} = FP32.normalise({0b1100, fraction})
  end

  test "encode FP32 12.375 => 0x41460000" do
    assert 0x41460000 == FP32.encode(12.375)
  end

  test "decode FP32 0x41460000 => 12.375" do
    assert 12.375 == FP32.decode(0x41460000)
  end

  test "encode/decode" do
    assert -0.375 = -0.375 |> FP32.encode() |> FP32.decode()
  end

  test "eq" do
    v1 = -10.750 |> FP32.encode()
    v2 = -10.750 |> FP32.encode()
    v3 = 0.750 |> FP32.encode()

    assert FP32.eq(v1, v2)
    assert !FP32.eq(v1, v3)
  end

  test "neq" do
    v1 = -10.750 |> FP32.encode()
    v2 = -10.750 |> FP32.encode()
    v3 = 0.750 |> FP32.encode()

    assert FP32.neq(v1, v3)
    assert !FP32.neq(v1, v2)
  end

  test "gt" do
    v1 = -10.750 |> FP32.encode()
    v2 = -5.750 |> FP32.encode()
    v3 = 0.750 |> FP32.encode()

    assert FP32.gt(v3, v2)
    assert !FP32.gt(v1, v2)
  end

  test "lt" do
    v2 = -10.750 |> FP32.encode()
    v3 = 0.750 |> FP32.encode()

    assert FP32.lt(v2, v3)
    assert !FP32.lt(v3, v2)
  end

  test "gte" do
    v1 = -10.750 |> FP32.encode()
    v2 = -10.750 |> FP32.encode()
    v3 = 0.750 |> FP32.encode()

    assert FP32.gte(v1, v2)
    assert FP32.gte(v3, v2)
    assert !FP32.gte(v1, v3)
  end

  test "lte" do
    v1 = -10.750 |> FP32.encode()
    v2 = -10.750 |> FP32.encode()
    v3 = 0.750 |> FP32.encode()

    assert FP32.lte(v1, v2)
    assert FP32.lte(v2, v3)
    assert !FP32.lte(v3, v2)
  end
end
