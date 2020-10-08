
defmodule Emulators.S5.AP.State do
  use Bitwise

  alias Emulators.S5.Block
  alias Emulators.State, as: ES 

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
          prev_mode: nil,
          changed_mode: false,
          
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
      } |> Map.merge(ES.new())
  end

  # Base functions
  def mode(state) do
    get_in(state, [:mode])
  end

  def set_mode(state, value) do
    put_in(state, [:prev_mode], mode(state))
    put_in(state, [:mode], value)
    put_in(state, [:changed_mode], true)
  end

  def mode_transition(state) do
    {get_in(state, [:mode]), get_in(state, [:prev_mode])}
  end

  def has_mode_changed(state) do
    get_in(state, [:changed_mode])
  end

  def ack_mode(state) do
    put_in(state, [:changed_mode], false)
  end

  def ptr(state, area) do
    get_in(state, [:specs, :ptr, area])
  end

  def set_ptr(state, area, address) do
    put_in(state, [:specs, :ptr, area], address)
  end

  def size(state, area) do
    get_in(state, [:specs, :size, area])
  end

  def set_size(state, area, size) do
    put_in(state, [:specs, :size, area], size)
  end

  def memory(state) do
    get_in(state, [:memory])
  end

  def set_memory(state, memory) do
    put_in(state, [:memory], memory)
  end

  def registers(state) do
    get_in(state, [:registers])
  end

  def set_registers(state, registers) do
    put_in(state, [:registers], registers)
  end

  # Memory-related functions
  def write(state, address, values) when is_list(values) do
    case values do
        [value | values] ->
            state 
                |> write(address, value)
                |> write(address + 1, values)
        [] -> state
    end
  end

  def write(state, address, value) do
    state |> set_memory(
            state 
                |> memory()
                |> List.update_at(address, fn _ -> value end)
    )
  end

  def read(state, address) do
    state |> memory |> Enum.fetch!(address)
  end

  def read(state, base, size) do
    Enum.slice(
        state |> memory,
        base,
        size
    )
  end

  def take_area(state, area)
  do
    size = state |> size(area)
    base = state |> ptr(area)
    state |> read(base, size)
  end

  # Blocks-related Functions
  def table_address(state, type, index) do
    state 
    |> ptr(:BLOCK_TABLE)
    |> Map.fetch(type)
    |> Kernel.+(index)
  end
  
  def register_block(state, type, index, block_address) do
    state |> write(
            state |> table_address(type, index), 
            block_address + 6
    )
  end

  def iterate_blocks(state, area, fb, fend \\ (fn state, _address, _memory -> state end)) 
  when area in [:DB, :USER]
  do
    base = state |> ptr(:USER)
    riterate_blocks(
        state, 
        {fb, fend}, 
        base, 
        take_area(state, area)
    )
  end

  defp riterate_blocks(state, {fb, fend}, address, memory) do
    case Block.read(memory) do
        {:ok, block} ->
            size = Block.size(block)
            new_address = address + size
            {_, new_memory} = Enum.split(memory, size)
            fb.(
                block, 
                address, 
                fn -> iterate_blocks(state, {fb, fend}, new_address, new_memory) end
            )
        _-> fend.(state, address, memory)
    end
  end

  def registered_blocks(state, type) do
    size = case type do
        :OB -> 48
        _ -> 256
    end

    base = table_address(state, type, 0)
    state |> read(base, size)
  end

  def block_address(state, type, index, from_header \\ false) do
    value = state   
        |> registered_blocks(type)
        |> Enum.fetch!(index)
    unless from_header do value - 6 else value end
  end

  def take_block!(state, type, index) do
    address = block_address(state, type, index, true)
    
    unless address > 0 do
        raise Emulators.S5.Errors.UnexistingBlockError, message: "Block #{type} n°#{index} does not exist."
    end

    Block.read!(state |> memory |> Enum.slice(address..-1))
  end

  def rewrite_block!(state, block) do
    type = block |> Block.type
    index = block |> Block.id
    new_block_size = block |> Block.size

    address = state |> block_address(type, index, true)
    
    unless address > 0 do
        raise Emulators.S5.Errors.UnexistingBlockError, message: "Block #{type} #{index} does not exist."
    end
    
    old_block = take_block!(state, type, index)
    old_block_size = old_block |> Block.size
    
    unless new_block_size == old_block_size do
        raise Emulators.S5.Errors.RewriteBlockError, message: "Cannot rewrite block #{type} #{index} as their block sizes do not match."
    end

    state |> write(address, Block.write(block))
  end

  def set_block_validity!(state, type, index) do
    block = take_block!(state, type, index) |> Block.set_validity(1)
    state |> rewrite_block!(block)
  end

  def write_block!(state, block, area \\ :USER) 
  when area in [:USER, :DB]
  do
    # We try to find space available
    {address, left} = state |> iterate_blocks(
        :USER,
        fn _, _, next -> next.() end,
        fn _, address, memory -> {address, memory} end 
    )

    data = Block.write(block)
    data_size = Enum.count(data)
    left_size = Enum.count(left)

    unless data_size <= left_size do
        raise Emulators.S5.Errors.MemoryExhaustedError, message: "No more memory available to write block."
    end

    state |> write(address, data)
  end

  # Call related functions
  def block_call(state, type, id)
  do
    # System OBs
    cond do
        type == :OB and id >= 40 ->
            # Trigger an interrupt at the emulator level 
            # to process the special function.
            state |> EmulatorState.interrupt({:CALL, [:OB, id]})
        true ->
            _block = state |> take_block!(type, id)
        
            _dba = block_address(state, type, id)
            _prev_sac = get(state, :SAC)
            _prev_dba = get(state, :DBA)
    end
  end

  def block_return(_state)
  do 
  end

  # Register-related functions
  def get(state, reg) do
    case reg do
        :CC -> state |> registers |> Map.fetch!(:CC)
        :RLO -> ((state |> get(:CC)) &&& 2) >>> 1
    end
  end

  def set(state, reg, value) do
    case reg do
        :CC -> 
            registers = state |> registers |> Map.put(:CC, value)
            state |> set_registers(registers)
        :RLO ->
            cc = (get(state, :CC) &&& (~~~2)) + ((value &&& 2) <<< 1)
            state |> set(:CC, cc)
    end
  end

  # Operand-related functions
  def operand_to_area(state, operand) do
    cond do
        operand in [:I, :IB, :IW, :ID] -> state |> ptr(:PII)
        operand in [:Q, :QB, :QW, :QD] -> state |> ptr(:PIQ)
        operand in [:F, :FY, :FW, :FD] -> state |> ptr(:FLAGS)
        operand in [:S, :SY, :SW, :SD] -> state |> ptr(:S_FLAGS)
    end
   end

  def operand_to_address(state, operand, address) do
    base = operand_to_area(state, operand)
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
            abs = operand_to_address(state, operand, address)
            ((state |> read(abs)) >>> bit) &&& 1
        
        # Byte access with 8-bits memory cases
        operand in [:IB, :QB, :FY, :SY] ->
            [address] = args
            abs = operand_to_address(state, operand, address)            
            read(state, abs)

        # Word access with 8-bits memory cases
        operand in [:IW, :QW, :FW, :SW] ->
            [address] = args
            abs = operand_to_address(state, operand, address)

            low = read(state, abs) &&& 0xFF
            high = (read(state, abs + 1) &&& 0xFF) <<< 8
      
            high + low
        # D-Word access with 8-bits memory cases
        operand in [:ID, :QD, :FD, :SD] ->
            [address] = args
            
            abs = operand_to_address(state, operand, address)

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
                abs = operand_to_address(state, operand, address)

                value = (value &&& 1) <<< bit
                value = (read(state, abs) &&& (~~~(0b1 <<< bit))) + value

                state 
                    |> write(abs, value)
            
            operand in [:IB, :QB, :FY, :SY] ->
                value = values
                [address] = args
                abs = operand_to_address(state, operand, address)

                state 
                    |> write(abs, value)

            operand in [:IW, :QW, :FW, :SW] ->
                value = values
                [address] = args

                abs = operand_to_address(state, operand, address)

                high = (0xFF00 &&& value) >>> 8
                low = 0x00FF &&& value

                state 
                    |> write(abs, low)
                    |> write(abs + 1, high)

            operand in [:ID, :QD, :FD, :SD] ->
                [address] = args
                [w0, w1] = values

                abs = operand_to_address(state, operand, address)
        
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
