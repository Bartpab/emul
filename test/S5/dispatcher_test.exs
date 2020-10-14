defmodule EmulatorsTest.S5.Dispatcher do
  use ExUnit.Case
  use Bitwise

  alias Emulators.S5.AP.GenState, as: State
  alias Emulators.S5.Dispatcher, as: Dispatcher

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
end
