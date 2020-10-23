defmodule Emulation.Common.FixedPointWord do
  use Bitwise

  def check_limits(v) do
    cond do
      v > 0x7FFF -> {:overflow, v}
      v < -1 * 0x8000 -> {:underflow, v}
      true -> {:ok, v}
    end
  end

  def multiply(v1, v2) do
    k = 1 <<< 7
    v = v1 * v2 + k
    check_limits(v >>> 8)
  end

  def divide(v1, v2) do
    result = div(v1, v2)
    remainder = rem(v1, v2)

    {result, remainder}
  end

  def substract(v1, v2) do
    v = v1 - v2
    check_limits(v)
  end

  def add(v1, v2) do
    v = v1 + v2
    check_limits(v)
  end
end
