defmodule Emulation.Common.ShiftRegister do
  use Bitwise

  def push_right(slot, value, at) do
    (slot >>> 1) + (value <<< at)
  end

  def push_left(slot, value) do
    (slot <<< 1) + value
  end

  def pop_right(slot) do
    {slot &&& 1, slot >>> 1}
  end

  def pop_left(slot, at) do
    mask = 1 <<< at
    {(slot &&& mask) >>> at, (slot &&& ~~~mask) <<< 1}
  end
end
