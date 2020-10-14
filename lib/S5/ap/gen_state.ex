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
          PB: %{},
          DB: %{}
        },
        PIQ: List.duplicate(0, 0xFF),
        PII: List.duplicate(0, 0xFF),
        F: List.duplicate(0, 0xFF),
        S: List.duplicate(0, 0xFF),
        P: List.duplicate(0, 0xFF),
        O: List.duplicate(0, 0xFF),
        IM3: List.duplicate(0, 0xFF),
        IM4: List.duplicate(0, 0xFF),
        IPC: List.duplicate(0, 0xFF),
        COORDINATOR_MODULE: List.duplicate(0, 0xFF),
        PAGES: List.duplicate(0, 0x800),
        DISTRIBUTED_IO: List.duplicate(0, 0x300)
      })

    state
    |> put_in([:ap], ap)
    |> put_in([:emulator, :stack], [])
  end

  # Instructions related
  def current_instr(state) do
    {type, id, offset} = state |> get(:SAC)
    state |> get_block(type, id) |> Enum.fetch!(offset)
  end

  def next_instr(state) do
    {type, id, offset} = state |> get(:SAC)
    state |> set(:SAC, {type, id, offset + 1})
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

  def open(state, id) do
    unless get_in(state, [:ap, :blocks, :DB]) |> Map.has_key?(id) do
      raise "Block DB #{id} does not exist in memory."
    end

    state
    |> set(:DBA, id)
    |> set(:DBL, state |> get_block(:DB, id) |> Enum.count())
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

        state
        |> push_bstack({0x0000, get(state, :SAC), get(state, :DBA), get(state, :DBA)})
        |> set(:SAC, {type, id, -1})
        |> put_in(
          [:emulator, :stack],
          get_in(state, [:emulator, :stack]) ++ [{type, id}]
        )
    end
  end

  def return(state) do
    [_, sac, dba, dbl] = state |> get_in([:ap, :bstack]) |> Enum.slice(1..4)
    [curr | tail] = state |> get_in([:emulator, :stack])

    state
    |> pop_bstack
    |> set(:SAC, sac)
    |> set(:DBA, dba)
    |> set(:DBL, dbl)
    |> put_in([:emulator, :stack], tail)
    |> ES.push({:BLOCK_RETURN, curr})
  end

  # Memory get/set
  def take_area!(state, area) do
    unless area == :D do
      state[:ap][area]
    else
      {type, id} = state |> get(:DBA)
      state |> get_in([:ap, :blocks, type, id])
    end
  end

  def write_area(state, area, values) do
    case area do
      :D ->
        {type, id} = state |> get(:DBA)
        state |> put_in([:ap, :blocks, type, id], values)

      other ->
        state |> put_in([:ap, other], values)
    end
  end

  def op2area(operand) do
    cond do
      operand in [:Q, :QB, :QW, :QD] -> :PIQ
      operand in [:I, :IB, :IW, :ID] -> :PII
      operand in [:PY, :PW] -> :P
      operand in [:OY, :OW] -> :O
      operand in [:F, :FY, :FW, :FD] -> :F
      operand in [:S, :SY, :SW, :SD] -> :S
      operand in [:DR, :DL, :DW, :DD] -> :D
    end
  end

  def op2shift(operand) do
    case operand do
      :DL -> 8
      _ -> 0
    end
  end

  def get_cell_size(area) do
    case area do
      :PIQ -> 8
      :PII -> 8
      :P -> 8
      :O -> 8
      :F -> 8
      :S -> 8
      :D -> 16
    end
  end

  def get_data_size(operand) do
    cond do
      operand in [:Q, :I, :F, :S] -> 1
      operand in [:QB, :IB, :PY, :OY, :FY, :SY, :DR, :DL] -> 8
      operand in [:QW, :IW, :PW, :OW, :FW, :SW, :DW] -> 16
      operand in [:QD, :ID, :FD, :SD, :DD] -> 32
    end
  end

  def get(state, operand, args) do
    data_size = get_data_size(operand)
    area_type = op2area(operand)
    cell_size = get_cell_size(area_type)

    cond do
      data_size == 1 ->
        [bit, addr] = args

        state
        |> take_area!(area_type)
        |> Enum.fetch!(addr)
        |> band(bsl(1, bit))
        |> bsr(bit)

      data_size > cell_size ->
        [addr] = args
        nb = (data_size / cell_size) |> trunc

        state
        |> take_area!(area_type)
        |> Enum.slice(addr, nb)
        |> Emulators.Utils.adjust(cell_size, data_size)
        |> Enum.fetch!(0)

      data_size == cell_size ->
        [addr] = args

        state
        |> take_area!(area_type)
        |> Enum.slice(addr, 1)
        |> Emulators.Utils.adjust(cell_size, data_size)
        |> Enum.fetch!(0)

      data_size < cell_size ->
        [addr] = args

        value =
          state
          |> take_area!(area_type)
          |> Enum.slice(addr, 1)
          |> Emulators.Utils.adjust(cell_size, data_size)
          |> Enum.fetch!(0)

        shift = op2shift(operand)
        value = value >>> shift
        flag = Emulators.Utils.expand_flag(data_size)
        value &&& flag
    end
  end

  def set(state, operand, args, value) when is_list(value) == false do
    state |> set(operand, args, [value])
  end

  def set(state, operand, args, values) when is_list(values) do
    data_size = get_data_size(operand)
    area_type = op2area(operand)
    cell_size = get_cell_size(area_type)

    cond do
      data_size == 1 ->
        [bit, addr] = args

        flag = ~~~(1 <<< bit)

        value =
          state
          |> take_area!(area_type)
          |> Enum.fetch!(addr)

        value = (value &&& flag) + (values |> Enum.fetch!(0) <<< bit)

        area =
          state
          |> take_area!(area_type)
          |> List.replace_at(addr, value)

        state
        |> write_area(area_type, area)

      data_size == cell_size ->
        [addr] = args

        value =
          values
          |> Emulators.Utils.adjust(data_size, cell_size)
          |> Enum.fetch!(0)

        area =
          state
          |> take_area!(area_type)
          |> List.replace_at(addr, value)

        state
        |> write_area(area_type, area)

      data_size > cell_size ->
        [addr] = args
        values = values |> Emulators.Utils.adjust(data_size, cell_size)

        area =
          state
          |> take_area!(area_type)
          |> Emulators.Utils.write(addr, values)

        state
        |> write_area(area_type, area)

      data_size < cell_size ->
        [addr] = args

        value =
          values
          |> Emulators.Utils.adjust(data_size, cell_size)
          |> Enum.fetch!(0)

        shift = op2shift(operand)
        value = value <<< shift
        flag = ~~~(Emulators.Utils.expand_flag(data_size) <<< shift)

        current_value =
          state
          |> take_area!(area_type)
          |> Enum.fetch!(addr)

        value = (current_value &&& flag) + value

        area =
          state
          |> take_area!(area_type)
          |> List.replace_at(addr, value)

        state
        |> write_area(area_type, area)
    end
  end
end
