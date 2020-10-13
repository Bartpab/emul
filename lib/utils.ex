defmodule Emulators.Utils do
  def compress_chunk(chunk, offset, src_size, dest_size) do
    case chunk do
      [head | tail] ->
        head <<< (offset * src_size + compress_chunk(tail, offset + 1, src_size, dest_size))

      [] ->
        0
    end
  end

  def compress_chunks(chunks, src_size, dest_size) do
    case chunks do
      [chunk | tail] ->
        [compress_chunk(chunk, 0, src_size, dest_size)]
        +compress_chunks(tail, src_size, dest_size)

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

  def expand_value(value, offset, src_size, dest_size) do
    max = src_size / dest_size

    shift = offset * dest_size
    flag = expand_flag(dest_size)
    flag <<< shift
    value = (value &&& flag) >>> shift

    if offset < max do
      [value] ++ expand_value(value, offset + 1, src_size, dest_size)
    else
      [value]
    end
  end

  def expand_values(values, src_size, dest_size) do
    case values do
      [value | tail] ->
        expand_value(value, 0, src_size, dest_size) ++ expand_values(tail, src_size, dest_size)

      [] ->
        []
    end
  end

  def compress_values(values, src_size, dest_size) do
    chunk_size = dest_size / src_size

    values
    |> Enum.chunk_every(chunk_size)
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
