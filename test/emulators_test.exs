defmodule EmulatorsTest do
  use ExUnit.Case
  doctest Emulators

  test "greets the world" do
    assert Emulators.hello() == :world
  end
end
