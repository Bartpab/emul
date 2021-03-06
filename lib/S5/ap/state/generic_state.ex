defmodule Emulation.S5.AP.GenericState do
  use Bitwise
  use Emulation.S5.AP.State.Utils
  use Emulation.S5.AP.CommonState
  alias Emulation.Emulator.State, as: ES

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
          DB: %{},
          DX: %{}
        },
        flags: %{
          enable_interrupts: false
        },
        interrupts: %{
          time: [
            {{:OB, 10}, {10, :millisecond}, 0, false, false},
            {{:OB, 11}, {20, :millisecond}, 0, false, false},
            {{:OB, 12}, {50, :millisecond}, 0, false, false},
            {{:OB, 13}, {100, :millisecond}, 0, false, false},
            {{:OB, 14}, {200, :millisecond}, 0, false, false},
            {{:OB, 15}, {500, :millisecond}, 0, false, false},
            {{:OB, 16}, {1, :second}, 0, false, false},
            {{:OB, 17}, {2, :second}, 0, false, false},
            {{:OB, 18}, {5, :second}, 0, false, false}
          ]
        },
        timer_ticks: List.duplicate(0, 0xFF),
        PIQ: List.duplicate(0, 0xFF),
        PII: List.duplicate(0, 0xFF),
        F: List.duplicate(0, 0xFF),
        S: List.duplicate(0, 0xFF),
        P: List.duplicate(0, 0xFF),
        O: List.duplicate(0, 0xFF),
        C: List.duplicate(0, 0xFF),
        T: List.duplicate(0, 0xFF),
        RI: List.duplicate(0, 0xFF),
        RJ: List.duplicate(0, 0xFF),
        RS: List.duplicate(0, 0xFF),
        RT: List.duplicate(0, 0xFF),
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

  # timer
  def set_timer_last_tick(state, timer_id, tick) do
    timers = get_in(state, [:ap, :timer_ticks])
    timers = timers |> List.replace_at(timer_id, tick)
    put_in(state, [:ap, :timer_ticks], timers)
  end

  def get_timer_last_tick(state, timer_id) do
    get_in(state, [:ap, :timer_ticks]) |> Enum.fetch!(timer_id)
  end

  # flags
  def set_flag(state, type, value) do
    put_in(state, [:ap, :flags, type], value)
  end

  def get_flag(state, type) do
    get_in(state, [:ap, :flags, type])
  end

  # time interruptions
  def get_time_interrupts(state) do
    get_in(state, [:ap, :interrupts, :time])
  end

  def set_time_interrupts(state, interrupts) do
    put_in(state, [:ap, :interrupts, :time], interrupts)
  end

  # Instructions related
  def current_instr(state) do
    {type, id, offset} = state |> get(:SAC)
    state |> get_block(type, id) |> Enum.fetch!(offset)
  end

  def next_instr(state) do
    case state |> get(:SAC) do
      {type, id, offset} ->
        state |> set(:SAC, {type, id, offset + 1})

      _ ->
        IO.inspect(state)
        raise "No more instructions..."
    end
  end

  # Block related
  def generate_block(state, type, id, size) do
    state |> write_block(type, id, List.duplicate(size, 0))
  end

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
    tail = get_in(state, [:ap, :bstack]) |> Enum.slice(4..-1)
    state |> put_in([:ap, :bstack], tail)
  end

  def open(state, type, id) do
    unless get_in(state, [:ap, :blocks, type]) |> Map.has_key?(id) do
      raise "Block DB #{id} does not exist in memory."
    end

    state
    |> set(:DBA, {type, id})
    |> set(:DBL, state |> get_block(:DB, id) |> Enum.count())
  end

  def call(state, type, id) do
    cond do
      # System OBs
      type == :OB and id >= 40 ->
        # Trigger an interrupt at the emulator level
        # to process the special function.
        state |> ES.push({:CALL, {:OB, id}})

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
        |> ES.push({:BLOCK_CALL, {type, id, :internal}})
    end
  end

  def return(state) do
    [_, sac, dba, dbl] = state |> get_in([:ap, :bstack]) |> Enum.slice(0..3)
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

  def write_area!(state, area, values) do
    case area do
      :D ->
        {type, id} = state |> get(:DBA)
        state |> put_in([:ap, :blocks, type, id], values)

      other ->
        state |> put_in([:ap, other], values)
    end
  end

  def get(_, operand, args)
      when is_constant(operand) do
    args |> Enum.fetch!(0)
  end

  def get(state, operand, args)
      when is_constant(operand) == false do
    data_size = get_data_size(operand)
    area_type = op2area(operand)
    cell_size = get_cell_size(area_type)

    cond do
      data_size == 1 ->
        state |> get_bit(operand, args)

      data_size > cell_size ->
        [addr] = args
        nb = (data_size / cell_size) |> trunc

        state
        |> take_area!(area_type)
        |> Enum.slice(addr, nb)
        |> Emulation.Common.Utils.adjust(cell_size, data_size)
        |> Enum.fetch!(0)

      data_size == cell_size ->
        [addr] = args

        state
        |> take_area!(area_type)
        |> Enum.slice(addr, 1)
        |> Emulation.Common.Utils.adjust(cell_size, data_size)
        |> Enum.fetch!(0)

      data_size < cell_size ->
        [addr] = args

        value =
          state
          |> take_area!(area_type)
          |> Enum.slice(addr, 1)
          |> Emulation.Common.Utils.adjust(cell_size, data_size)
          |> Enum.fetch!(0)

        shift = op2shift(operand)
        value = value >>> shift
        flag = Emulation.Common.Utils.expand_flag(data_size)
        value &&& flag
    end
  end

  def set(state, operand, args, value) when is_list(value) == false do
    state |> set(operand, args, [value])
  end

  def get_bit(state, operand, args) do
    area_type = op2area(operand)
    [bit, addr] = args

    state
    |> take_area!(area_type)
    |> Enum.fetch!(addr)
    |> band(bsl(1, bit))
    |> bsr(bit)
  end

  def set_bit(state, operand, args, value) do
    area_type = op2area(operand)
    [bit, addr] = args

    value = value &&& 1

    flag = ~~~(1 <<< bit)

    curr =
      state
      |> take_area!(area_type)
      |> Enum.fetch!(addr)

    value = (curr &&& flag) + (value <<< bit)

    area =
      state
      |> take_area!(area_type)
      |> List.replace_at(addr, value)

    state
    |> write_area!(area_type, area)
  end

  def set(state, operand, args, values) when is_list(values) do
    data_size = get_data_size(operand)
    area_type = op2area(operand)
    cell_size = get_cell_size(area_type)

    cond do
      data_size == 1 ->
        state |> set_bit(operand, args, values |> Enum.fetch!(0))

      # Special case
      operand in [:T, :C] and args |> Enum.count() == 2 ->
        state |> set_bit(operand, args, values |> Enum.fetch!(0))

      data_size == cell_size ->
        [addr] = args

        value =
          values
          |> Emulation.Common.Utils.adjust(data_size, cell_size)
          |> Enum.fetch!(0)

        area =
          state
          |> take_area!(area_type)
          |> List.replace_at(addr, value)

        state
        |> write_area!(area_type, area)

      data_size > cell_size ->
        [addr] = args
        values = values |> Emulation.Common.Utils.adjust(data_size, cell_size)

        area =
          state
          |> take_area!(area_type)
          |> Emulation.Common.Utils.write(addr, values)

        state
        |> write_area!(area_type, area)

      data_size < cell_size ->
        [addr] = args

        value =
          values
          |> Emulation.Common.Utils.adjust(data_size, cell_size)
          |> Enum.fetch!(0)

        shift = op2shift(operand)
        value = value <<< shift
        flag = ~~~(Emulation.Common.Utils.expand_flag(data_size) <<< shift)

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
        |> write_area!(area_type, area)
    end
  end
end
