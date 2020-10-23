defmodule Emulation.Common.FP32 do
  use Bitwise
  alias Emulation.Common.ShiftRegister

  def decode(value) do
    {sign, exponent, fraction} = repr_decode(value)
    :math.pow(-1, sign) * (1.0 + fraction) * :math.pow(2, exponent - 127)
  end

  def repr_decode(value) do
    sign = value >>> 31
    exponent = (value &&& 0xFF <<< 23) >>> 23
    fraction = (value &&& 0x7FFFFF) |> trunc |> decode_fraction

    {sign, exponent, fraction}
  end

  def decode_fraction(fraction, index \\ 0) do
    rank = index + 1

    if index == 22 do
      0
    else
      {digit, fraction} = ShiftRegister.pop_left(fraction, 22)
      digit * :math.pow(2, -rank) + decode_fraction(fraction, index + 1)
    end
  end

  def encode_fraction(fraction, value, index, max) do
    case fraction do
      0.0 ->
        value

      fraction ->
        fraction = fraction * 2
        digit = rem(fraction |> trunc, 2)

        if index <= max do
          encode_fraction(fraction, value, index + 1, max)
          |> ShiftRegister.push_right(digit, 22)
        else
          value
        end
    end
  end

  def normalise({integer, fraction}, exponent \\ 0) do
    cond do
      integer == 0 and fraction == 0 ->
        {{0, 0}, exponent}

      integer == 0 and fraction != 0 ->
        {digit, fraction} = ShiftRegister.pop_left(fraction, 22)
        integer = ShiftRegister.push_left(integer, digit)
        normalise({integer, fraction}, exponent - 1)

      integer > 1 ->
        {digit, integer} = ShiftRegister.pop_right(integer)
        fraction = ShiftRegister.push_right(fraction, digit, 22)
        normalise({integer, fraction}, exponent + 1)

      integer == 1 ->
        {{integer, fraction}, exponent}
    end
  end

  def encode(value) do
    sign =
      if value >= 0 do
        0
      else
        1
      end

    integer = abs(value |> trunc)
    fraction = (abs(value) - integer) |> encode_fraction(0, 0, 22)
    {{_, mantisse}, exponent} = normalise({integer, fraction})
    exponent = 127 + exponent
    (sign <<< 31) + (exponent <<< 23) + mantisse
  end

  def eq(v1, v2) do
    v1 == v2
  end

  def neq(v1, v2) do
    !eq(v1, v2)
  end

  def gt(v1, v2) do
    {v1_sign, v1_exp, v1_mant} = repr_decode(v1)
    {v2_sign, v2_exp, v2_mant} = repr_decode(v2)

    cond do
      # 1 means neg, 0 means positive or zero
      v1_sign > v2_sign -> false
      v1_exp < v2_exp -> true
      v1_mant > v2_mant -> true
      true -> false
    end
  end

  def lt(v1, v2) do
    !gt(v1, v2) and !eq(v1, v2)
  end

  def gte(v1, v2) do
    gt(v1, v2) or eq(v1, v2)
  end

  def lte(v1, v2) do
    !gt(v1, v2)
  end

  def add(v1, v2) do
    v1 |> decode

    +(v2 |> decode)
    |> encode
  end

  def substract(v1, v2) do
    v1 |> decode

    -(v2 |> decode)
    |> encode
  end

  def multiply(v1, v2) do
    ((v1 |> decode) *
       (v2 |> decode))
    |> encode
  end

  def divide(v1, v2) do
    ((v1 |> decode) /
       (v2 |> decode))
    |> encode
  end
end
