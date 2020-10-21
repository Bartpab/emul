defmodule EmulationTest.S5.Dispatcher do
  use ExUnit.Case
  use Bitwise

  alias Emulation.S5.AP.StateDispatcher, as: State
  alias Emulation.S5.Dispatcher, as: Dispatcher

  def start() do
    State.new()
  end

  test "dispatch A I 0xF.1 with 1 and 0" do
    instr = {:A, :I, [1, 0xF]}

    assert 1 ==
             start()
             |> State.set(:I, [1, 0xF], 1)
             |> State.set(:RLO, 1)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:RLO)

    assert 0 ==
             start()
             |> State.set(:I, [1, 0xF], 0)
             |> State.set(:RLO, 1)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:RLO)
  end

  test "dispatch AN I 0xF.1 with 1 and 0" do
    instr = {:AN, :I, [1, 0xF]}

    assert 0 ==
             start()
             |> State.set(:I, [1, 0xF], 1)
             |> State.set(:RLO, 1)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:RLO)

    assert 1 ==
             start()
             |> State.set(:I, [1, 0xF], 0)
             |> State.set(:RLO, 1)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:RLO)
  end

  test "dispatch O I 0xF.1 with 1 and 0" do
    instr = {:O, :I, [1, 0xF]}

    assert 1 ==
             start()
             |> State.set(:I, [1, 0xF], 0)
             |> State.set(:RLO, 1)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:RLO)

    assert 0 ==
             start()
             |> State.set(:I, [1, 0xF], 0)
             |> State.set(:RLO, 0)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:RLO)
  end

  test "dispatch ON I 0xF.1 with 1 and 0" do
    instr = {:ON, :I, [1, 0xF]}

    assert 0 ==
             start()
             |> State.set(:I, [1, 0xF], 0)
             |> State.set(:RLO, 1)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:RLO)

    assert 1 ==
             start()
             |> State.set(:I, [1, 0xF], 0)
             |> State.set(:RLO, 0)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:RLO)
  end

  test "dispatch S 0xF.1 with RLO in {1,0}" do
    instr = {:S, :I, [1, 0xF]}

    assert 1 ==
             start()
             |> State.set(:I, [1, 0xF], 0)
             |> State.set(:RLO, 1)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:I, [1, 0xF])

    assert 0 ==
             start()
             |> State.set(:I, [1, 0xF], 0)
             |> State.set(:RLO, 0)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:I, [1, 0xF])
  end

  test "dispatch R 0xF.1 with RLO in {1,0}" do
    instr = {:R, :I, [1, 0xF]}

    assert 0 ==
             start()
             |> State.set(:I, [1, 0xF], 1)
             |> State.set(:RLO, 1)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:I, [1, 0xF])

    assert 1 ==
             start()
             |> State.set(:I, [1, 0xF], 1)
             |> State.set(:RLO, 0)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:I, [1, 0xF])
  end

  test "dispatch = 0xF.1 with RLO in {1,0}" do
    instr = {:assign, :I, [1, 0xF]}

    assert 1 ==
             start()
             |> State.set(:I, [1, 0xF], 0)
             |> State.set(:RLO, 1)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:I, [1, 0xF])

    assert 0 ==
             start()
             |> State.set(:I, [1, 0xF], 1)
             |> State.set(:RLO, 0)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:I, [1, 0xF])
  end

  test "dispatch L IB 0xF with IB 0xF = 0xBA" do
    instr = {:L, :IB, [0xF]}

    assert 0xBA ==
             start()
             |> State.set(:IB, [0xF], 0xBA)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:ACCU_1_L)
  end

  test "dispatch L IW 0xF with IW 0xF = 0xDCBA" do
    instr = {:L, :IW, [0xF]}

    assert 0xBADC ==
             start()
             |> State.set(:IW, [0xF], 0xDCBA)
             |> Dispatcher.dispatch(State, instr)
             |> State.get(:ACCU_1_L)
  end
end
