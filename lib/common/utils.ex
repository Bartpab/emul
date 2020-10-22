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

defmodule Emulation.Common.FP32 do
  use Bitwise
  alias Emulation.Common.ShiftRegister

  def decode(value) do
    sign = value >>> 31
    exponent = (value &&& (0xFF <<< 23)) >>> 23
    fraction = (value &&& 0x7FFFFF) |> trunc |> decode_fraction

    :math.pow(-1, sign) * (1.0 + fraction) * :math.pow(2, exponent - 127)
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
    sign = if value >= 0 do 0 else 1 end

    integer = abs(value |> trunc)
    fraction = (abs(value) - integer) |> encode_fraction(0, 0, 22)
    {{_, mantisse}, exponent} = normalise({integer, fraction})
    exponent = 127 + exponent
    (sign <<< 31) + (exponent <<< 23) + mantisse
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

defmodule Emulation.Common.Utils do
  use Bitwise

  def to_bcd(value) do
    read_decimals(value)
    |> to_bcd(0)
  end

  def to_bcd(decimals, index) do
    case decimals do
      [digit | tail] ->
        shift = index * 4
        digit <<< (shift + to_bcd(tail, index + 1))

      [] ->
        0
    end
  end

  def from_bcd(binary, size) do
    read_decimals_from_bcd(binary, 0, size)
  end

  def read_decimals_from_bcd(value, index, size) do
    if index >= size do
      0
    else
      shift = index * 4
      mask = 0xF <<< shift
      digit = mask &&& value
      :math.pow(10, index) * digit + read_decimals_from_bcd(value, index + 1, size)
    end
  end

  def read_decimals(value, begin \\ true) do
    cond do
      value == 0 and !begin ->
        []

      value == 0 and begin ->
        [0] ++ read_decimals(value / 10, false)

      true ->
        digit = rem(value, 10)
        [digit] ++ read_decimals(value / 10, false)
    end
  end

  def compress_chunk(chunk, index, src_size, dest_size, endianess \\ :little_end) do
    max = ((dest_size / src_size) |> trunc) - 1

    shift =
      case endianess do
        :little_end -> (max - index) * src_size
        :big_end -> index * src_size
      end

    case chunk do
      [head | tail] ->
        (head <<< shift) + compress_chunk(tail, index + 1, src_size, dest_size)

      [] ->
        0
    end
  end

  def compress_chunks(chunks, src_size, dest_size) do
    case chunks do
      [chunk | tail] ->
        [compress_chunk(chunk, 0, src_size, dest_size)] ++
          compress_chunks(tail, src_size, dest_size)

      [] ->
        []
    end
  end

  def expand_flag(offset) do
    if offset == 0 do
      1
    else
      (1 <<< offset) + expand_flag(offset - 1)
    end
  end

  def expand_value(value, index, src_size, dest_size) do
    max = ((src_size / dest_size) |> trunc) - 1

    shift = (max - index) * dest_size
    flag = expand_flag(dest_size - 1)
    flag = flag <<< shift
    part = (value &&& flag) >>> shift

    if index < max do
      [part] ++ expand_value(value, index + 1, src_size, dest_size)
    else
      [part]
    end
  end

  def expand_values(values, src_size, dest_size) do
    case values do
      [value | tail] ->
        expand_value(value, 0, src_size, dest_size) ++
          expand_values(tail, src_size, dest_size)

      [] ->
        []
    end
  end

  def compress_values(values, src_size, dest_size) do
    chunk_size = dest_size / src_size

    values
    |> Enum.chunk_every(chunk_size |> trunc)
    |> compress_chunks(src_size, dest_size)
  end

  def adjust(data, src_size, dest_size) do
    ratio = dest_size / src_size

    cond do
      ratio == 1 -> data
      ratio > 1 -> data |> compress_values(src_size, dest_size)
      ratio < 1 -> data |> expand_values(src_size, dest_size)
    end
  end

  def write(dest, base, values, offset \\ 0) do
    case values do
      [head | tail] ->
        dest
        |> List.replace_at(base + offset, head)
        |> write(base, tail, offset + 1)

      [] ->
        dest
    end
  end
end
