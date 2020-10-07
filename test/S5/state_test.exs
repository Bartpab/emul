defmodule EmulatorsTest.S5.State do
  use ExUnit.Case
  use Bitwise
  alias Emulators.S5.State
  doctest Emulators

  test "new" do
    assert state = State.new
  end

  test "RLO set/get" do
    state = State.new

    assert 0 = state |> State.get(:RLO)
    state = state |> State.set(:RLO, 1)
    assert 1 = state |> State.get(:RLO)
  end

  test "I set/get" do
    state = State.new

    assert 0 = state |> State.get(:I, [1, 0xF])
    state = state |> State.set(:I, [1, 0xF], 1)
    assert 1 = state |> State.get(:I, [1, 0xF])
  end

  test "Q set/get" do
    state = State.new

    assert 0 = state |> State.get(:Q, [1, 0xF])
    state = state |> State.set(:Q, [1, 0xF], 1)
    assert 1 = state |> State.get(:Q, [1, 0xF])
  end

  test "F set/get" do
    state = State.new

    assert 0 = state |> State.get(:F, [1, 0xF])
    state = state |> State.set(:F, [1, 0xF], 1)
    assert 1 = state |> State.get(:F, [1, 0xF])
  end

  test "S set/get" do
    state = State.new

    assert 0 = state |> State.get(:S, [1, 0xF])
    state = state |> State.set(:S, [1, 0xF], 1)
    assert 1 = state |> State.get(:S, [1, 0xF])
  end

  test "IB set/get" do
    state = State.new

    assert 0x00 = state |> State.get(:IB, [0xF])
    state = state |> State.set(:IB, [0xF], 0xBA)
    assert 0xBA = state |> State.get(:IB, [0xF])
  end

  test "QB set/get" do
    state = State.new

    assert 0x00 = state |> State.get(:QB, [0xF])
    state = state |> State.set(:QB, [0xF], 0xBA)
    assert 0xBA = state |> State.get(:QB, [0xF])
  end

  test "FY set/get" do
    state = State.new

    assert 0x00 = state |> State.get(:FY, [0xF])
    state = state |> State.set(:FY, [0xF], 0xBA)
    assert 0xBA = state |> State.get(:FY, [0xF])
  end

  test "SY set/get" do
    state = State.new

    assert 0x00 = state |> State.get(:SY, [0xF])
    state = state |> State.set(:SY, [0xF], 0xBA)
    assert 0xBA = state |> State.get(:SY, [0xF])
  end

  test "IW set/get" do
    state = State.new
    assert 0x0000 = state |> State.get(:IW, [0xF])
    state = state |> State.set(:IW, [0xF], 0xDCBA)
    assert 0xDCBA = state |> State.get(:IW, [0xF])
  end

  test "QW set/get" do
    state = State.new
    assert 0x0000 = state |> State.get(:QW, [0xF])
    state = state |> State.set(:QW, [0xF], 0xDCBA)
    assert 0xDCBA = state |> State.get(:QW, [0xF])
  end

  test "FW set/get" do
    state = State.new
    assert 0x0000 = state |> State.get(:FW, [0xF])
    state = state |> State.set(:FW, [0xF], 0xDCBA)
    assert 0xDCBA = state |> State.get(:FW, [0xF])
  end

  test "SW set/get" do
    state = State.new
    assert 0x0000 = state |> State.get(:SW, [0xF])
    state = state |> State.set(:SW, [0xF], 0xDCBA)
    assert 0xDCBA = state |> State.get(:SW, [0xF])
  end
end
