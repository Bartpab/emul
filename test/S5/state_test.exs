defmodule EmulatorsTest.S5.StateManager do
  use ExUnit.Case
  use Bitwise
  alias Emulators.S5.StateManager
  doctest Emulators

  test "new" do
    assert state = StateManager.new
  end
end
