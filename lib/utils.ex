defmodule Emulators.Utils do
  use Bitwise

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
end
