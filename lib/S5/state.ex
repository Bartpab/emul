defmodule Emulators.S5.Errors.UnexistingBlockError do
    defexception message: "Block does not exist."
end

defmodule Emulators.S5.Errors.RewriteBlockError do
    defexception message: "The block cannot be rewritten."
end

defmodule Emulators.S5.Errors.MemoryExhaustedError do
    defexception message: "No more memory."
end

defmodule Emulators.S5.State do
  use Bitwise

  alias Emulators.S5.Block

  def new() do
      sizes = %{
          USER: 0xFA00,
          DB: 0x5D7F,
          DB0: 0x67F,
          S_FLAGS: 0x3FF,
          RI: 0xFF,
          RJ: 0xFF,
          RS: 0xFF,
          RT: 0xFF,
          COUNTERS: 0xFF,
          TIMERS: 0xFF,
          FLAGS: 0xFF,
          PII: 0x80,
          PIQ: 0x80
      }

      ptrs = %{
          USER:      0x0000,
          DB:        0x8000,
          DB0:       0xDD80,
          S_FLAGS:   0xE400,
          RI:        0xEA00,
          RS:        0xE800,
          COUNTERS:  0xEC00,
          TIMERS:    0xED00,
          FLAGS:     0xEE00,
          PII:       0xEF00,
          PIQ:       0xEF80,          
      }

      # Set Data Blocks Table Ptr
      tables = %{}
      tables = tables
        |> Map.put(:DX, ptrs[:DB0])
        |> Map.put(:FX, ptrs[:DB0] + 0x100)
        |> Map.put(:DB, ptrs[:DB0] + 0x100 * 2)
        |> Map.put(:SB, ptrs[:DB0] + 0x100 * 3)
        |> Map.put(:PB, ptrs[:DB0] + 0x100 * 4)
        |> Map.put(:FB, ptrs[:DB0] + 0x100 * 5)
        |> Map.put(:OB, ptrs[:DB0] + 0x100 * 6)

      ptrs = ptrs |> Map.put(:BLOCK_TABLE, tables)

      %{
          mode: :POWER_OFF,
          memory: List.duplicate(0, 0xFFFF),
          registers: %{
              ACCU_1_H: 0x0000,
              ACCU_1_L: 0x0000,
              ACCU_2_H: 0x0000,
              ACCU_2_L: 0x0000,
              BSP: 0x0000,
              DBA: 0x0000,
              DBL: 0x0000,
              SAC: 0x0000,
              ACCU_3_H: 0x0000,
              ACCU_3_L: 0x0000,
              ACCU_4_H: 0x0000,
              ACCU_5_L: 0x0000,
              CC: 0x0000
          },
          specs: %{
              special_function_OB: 40
              ptr: ptrs,
              size: sizes,
              regmap: %{
                  0 => :ACCU_1_H,
                  1 => :ACCU_1_L,
                  2 => :ACCU_2_H,
                  3 => :ACCU_2_L,
                  5 => :BSA,
                  6 => :DBA,
                  8 => :DBL,
                  9 => :ACCU_3_H,
                  10 => :ACCU_3_L,
                  11 => :ACCU_4_H,
                  12 => :ACCU_4_L
              }
          }
      }
  end

  # Blocks-related Functions
  def iterate_blocks(state, area, fb, fend \\ fn state, address, memory -> state) 
  when area in [:DB, :USER]
  do
    ptr = state[:specs][:ptr][:USER]
    iterate_blocks(state, {fb, fend}, ptr, take_area(state, address))
  end

  def iterate_blocks(state, {fb, fend}, address, memory) do
    case Block.read(memory) do
        {:ok, block} ->
            size = block[:size]
            new_address = address + size
            {_, new_memory} = Enum.split(memory, size)
            fb.(
                block, 
                address, 
                fn -> iterate_blocks(state, {fb, fend}, new_address, new_memory)
            )
        _-> fend.(state, address, memory)
    end
  end

  def registered_blocks(state, block_type) do
    size = cond block_type do
        :OB -> 48
        _ -> 256
    end

    base = state[:specs][:ptr][:BLOCK_TABLE][block_type]

    state[:memory] 
        |> Enum.slice(base, size)
  end

  def block_entry(state, block_type, index, from_header \\ false) do
    addr = state   
        |> registered_blocks(block_type)
        |> Enum.fetch!(index)
    
    unless from_header do
        addr -= 6
    end
    addr
  end

  def register_block(state, block_type, index, address) do
    state |> write(index, address)
  end

  def set_block_validity!(state, type, index) do
    block = take_block!(state, type, index) |> Block.set_validity(1)
    state |> rewrite_block!(block)
  end

  def take_block!(%{:memory => memory} = state, type, index) do
    address = block_entry(state, type, index, flag, true)
    
    unless address > 0 do
        raise Emulators.S5.Errors.UnexistingBlockError, message: "Block #{type} n°#{index} does not exist."
    end

    Block.read!(memory |> Enum.slice(address..-1))
  end

  def write_block!(%{memory => memory} = state, block, area \\ :USER) 
  when area in [:USER, :DB]
  do
    {address, left} = state |> iterate_blocks(
        :USER,
        fn _, _, next() -> next() end,
        fn _, address, memory -> {address, memory} end 
    )

    data = Block.write(block)
    data_size = Enum.count(data)
    left_size = Enum.count(memory)

    unless data_size <= left_size do
        raise Emulators.S5.Errors.MemoryExhaustedError, message: "No more memory available to write block."
    end

    state |> write(address, data)
  end

  def rewrite_block!(%{:memory => memory} = state, block) do
    headers = block[:headers]
    type = headers[:type]
    id = headers[:id]
    new_block_size = headers[:size]

    address = block_entry(state, type, id, true)
    
    unless address > 0 do
        raise Emulators.S5.Errors.UnexistingBlockError, message: "Block #{type} n°#{index} does not exist."
    end
    
    old_block = take_block!(state, type, id)
    old_block_size = old_block[:headers][:size]
    
    unless new_block_size == old_block_size do
        raise Emulators.S5.Errors.RewriteBlockError, message: "Cannot rewrite block #{type} at #{id} as their block sizes do not match."
    end

    state |> write_memory(address, Block.write(block))
  end

  def take_area(state, area)
  do
    memory = state[:memory]
    size = state[:specs][:sizes][area]
    base = state[:specs][:sizes][area]

    memory |> Enum.slice(base, size)
  end

  def change_mode(state, mode) do
    state |> Map.put(:mode, mode)
  end

  def write(%{:memory => memory} = state, address, values) when is_list(values) do
    for {value, index} <- (values |> Enum.with_index) do
        state = state |> write(address + index, value)
    end   
    state
  end

  def write(%{:memory => memory} = state, address, value) do
    state |> Map.put(
            :memory, 
            memory |> List.update_at(address, fn _ -> value end)
        )
  end

  def read(%{:memory => memory}, address) do
    memory |> Enum.fetch!(address)
  end

  def get(%{:registers => registers}, :RLO) do
      (registers[:CC] &&& 0b10) >>> 1
  end

  def set(%{:registers => registers} = state, :RLO, value) do
      cc = (registers[:CC] &&& (~~~0b10)) + ((value &&& 0b1) <<< 1)
      state |> Map.put(:registers, (registers |> Map.put(:CC, cc)))
  end

  def base(%{:specs => %{:ptr => ptr}}, operand) do
      cond do
          operand in [:I, :IB, :IW, :ID] -> ptr[:PII]
          operand in [:Q, :QB, :QW, :QD] -> ptr[:PIQ]
          operand in [:F, :FY, :FW, :FD] -> ptr[:FLAGS]
          operand in [:S, :SY, :SW, :SD] -> ptr[:S_FLAGS]
      end
  end

  def bpush(state, block_type, block_id):
  do
    block = state |> get_block(block_type, block_id)
  end

  def abs(state, operand, address) do
    base = base(state, operand)
    cond do
        operand in [:I, :Q, :F, :S, :D] -> base + address
        operand in [:IW, :QW, :FW, :SW] -> base + address * 2
        operand in [:ID, :QD, :FD, :SD] -> base  + address * 4
        true -> base + address
    end
  end

  def get(state, operand, args)
  do
    cond do
        operand in [:I, :Q, :F, :S, :D] ->
            [bit, address] = args
            abs = abs(state, operand, address)
            ((state |> read(abs)) >>> bit) &&& 1
        
        # Byte access with 8-bits memory cases
        operand in [:IB, :QB, :FY, :SY] ->
            [address] = args
            abs = abs(state, operand, address)            
            read(state, abs)

        # Word access with 8-bits memory cases
        operand in [:IW, :QW, :FW, :SW] ->
            [address] = args
            abs = abs(state, operand, address)

            low = read(state, abs) &&& 0xFF
            high = (read(state, abs + 1) &&& 0xFF) <<< 8
      
            high + low
        # D-Word access with 8-bits memory cases
        operand in [:ID, :QD, :FD, :SD] ->
            [address] = args
            
            abs = abs(state, operand, address)

            b0 = read(state, abs)
            b1 = read(state, abs + 1)
            b2 = read(state, abs + 2)
            b3 = read(state, abs + 3)

            [b1 + b0, b2 + b3]
    end
  end

  def set(state, operand, args, values)
  do
        cond do
            operand in [:I, :Q, :F, :S, :D] ->
                value = values
                [bit, address] = args
                abs = abs(state, operand, address)

                value = (value &&& 1) <<< bit
                value = (read(state, abs) &&& (~~~(0b1 <<< bit))) + value

                state 
                    |> write(abs, value)
            
            operand in [:IB, :QB, :FY, :SY] ->
                value = values
                [address] = args
                abs = abs(state, operand, address)

                state 
                    |> write(abs, value)

            operand in [:IW, :QW, :FW, :SW] ->
                value = values
                [address] = args

                abs = abs(state, operand, address)

                high = (0xFF00 &&& value) >>> 8
                low = 0x00FF &&& value

                state 
                    |> write(abs, low)
                    |> write(abs + 1, high)

            operand in [:ID, :QD, :FD, :SD] ->
                [address] = args
                [w0, w1] = values

                abs = abs(state, operand, address)
        
                b0 = w0 &&& 0xFF
                b1 = (w0 &&& 0xFF00) >>> 8
                b2 = w1 &&& 0xFF
                b3 = (w0 &&& 0xFF00) >>> 8
        
                state
                    |> write(abs, b0)
                    |> write(abs, b1)
                    |> write(abs, b2)
                    |> write(abs, b3)             
        end
  end
end
