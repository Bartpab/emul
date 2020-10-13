defmodule Emulators.S5.AP.GenState do
  use Bitwise
  use Emulators.S5.AP.CommonState
  alias Emulators.State, as: ES

  def init(state) do
    ap =
      get_in(state, [:ap])
      |> Map.merge(%{
        type: :GENERIC,
        bstack: [],
        blocks: %{
          OB: %{},
          FB: %{},
          PB: %{}
        }
      })

    state |> put_in([:ap], ap)
  end

  # Instructions related
  def curr_instr(state) do
    sac = state |> get(:SAC)
    {type, id} = state |> get(:DBA)

    state |> get_block(type, id) |> Enum.fetch!(sac)
  end

  # Block related
  def write_block(state, type, id, instrs) do
    state |> put_in([:ap, :blocks, type, id], instrs)
  end

  def get_block(state, type, id) do
    get_in(state, [:ap, :blocks, type, id])
  end

  def has_block(state, type, id) do
    get_in(state, [:ap, :blocks, type])
    |> Map.has_key?(id)
  end

  def push_bstack(state, {offset, sac, dba, dbl}) do
    bstack = get_in(state, [:ap, :bstack])
    bstack = [offset, sac, dba, dbl] ++ bstack
    put_in(state, [:ap, :bstack], bstack)
  end

  def pop_bstack(state) do
    tail = Enum.slice(4..-1, get_in(state, [:ap, :bstack]))
    state |> put_in([:ap, :bstack], tail)
  end

  def call(state, type, id) do
    cond do
      # System OBs
      type == :OB and id >= 40 ->
        # Trigger an interrupt at the emulator level
        # to process the special function.
        state |> ES.interrupt({:CALL, {:OB, id}})

      type == :FB and id in [0, 1] ->
        state |> ES.interrupt({:CALL, {:FB, id}})

      true ->
        unless has_block(state, type, id) do
          raise "Block #{type} #{id} does not exist in memory."
        end

        dba = %{type: type, id: id}
        dbl = state |> get_block(type, id) |> Enum.count()
        ret = get(state, :SAC)

        state |> push_bstack({0x0000, ret, dba, dbl})
    end
  end

  def return(state) do
    [_, sac, old_dba, _] = get_in(state, [:ap, :bstack]) |> Enum.slice(1..4)
    tail = get_in(state, [:ap, :bstack]).slice(4..-1)

    dba = 0
    dbl = 0

    if tail |> Enum.count() >= 4 do
      [_, _, dba, dbl] = tail
    end

    state
    |> pop_bstack
    |> set(:SAC, sac)
    |> set(:DBA, dba)
    |> set(:DBL, dbl)
    |> ES.push({:BLOCK_RETURN, old_dba})
  end
end
