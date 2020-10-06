defmodule Emulators.S5.StateManager do
    use Bitwise
    import Emulators.S5.Guards

    def new() do
        sizes = %{
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

        %{
            memory: List.duplicate(0, 0xFFFF), 
            registers: %{
                ACCU_1_H: 0x0000,
                ACCU_1_L: 0x0000,
                ACCU_2_H: 0x0000,
                ACCU_2_L: 0x0000,
                BSP: 0x0000,
                DBA: 0x0000,
                DBL: 0x0000,
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
            },

            sm: __MODULE__
        }
    end

    def write_memory(%{:memory => memory} = state, address, value) do
        Map.put(state, :memory, List.update_at(memory, address, value))
    end

    def read_memory(%{:memory => memory}, address) do
        memory[address]
    end

    def get(%{:registers => registers}, :RLO) do
        registers[:CC] &&& 0b10 >>> 1
    end

    def set(%{:registers => registers} = state, :RLO, value) do
        cc = registers[:CC] &&& (~~~0b10) + ((value &&& 0b1) <<< 1)
        state |> Map.update!(:registers, (registers |> Map.update!(:CC, cc)))
    end

    def base(%{:specs => %{:ptr => ptr}}, operand) do
        cond do
            operand in [:I, :IB, :IW, :ID] -> ptr[:PII]
            operand in [:Q, :QB, :QW, :QD] -> ptr[:PIQ]
            operand in [:F, :FY, :FW, :FD] -> ptr[:FLAGS]
            operand in [:S, :SY, :SW, :SD] -> ptr[:S_FLAGS]
        end
    end

    # Bit access with 8-bits and 16-bits memory cases
    def get(%{:sm => sm} = state, operand, [bit, address]) 
    when operand in [:I, :Q, :F, :S, :D] do
        base = state|> sm.base(operand)
        ((state |> sm.read_memory(base + address)) >>> bit) &&& 1
    end

    def set(%{:sm => sm} = state, operand, [bit, address], value) 
    when operand in [:I, :Q, :F, :S, :D] 
    do
        value = (value &&& 1) <<< bit
        base = state|> sm.base(operand)
        abs_address = base + address
        new_value = sm.read_memory(state, abs_address) &&& (~~~(0b1 <<< bit)) # Reset the bit
        new_value = new_value + value
        state |> sm.write_memory(abs_address, new_value)
    end

    # Word access with 8-bits memory cases
    def get(%{:sm => sm} = state, operand, [address]) 
    when operand in [:IW, :QW, :FW, :SW]
    do
        base = state |> sm.base(operand)
        abs_address = address * 2

        low = sm.get(state, operand, abs_address) &&& 0xFF
        high = (sm.get(state, operand, abs_address) &&& 0xFF) <<< 8

        high + low
    end

    def set(%{:sm => sm} = state, operand, [address], value)
    when operand in [:IW, :QW, :FW, :SW, :PW, :OW]
    do
        low = value &&& 0xFF
        high = (value &&& 0xFF00) >>> 8

        base = state |> sm.base(operand)
        abs_address = address * 2

        state 
            |> sm.write_memory(abs_address, low)
            |> sm.write_memory(abs_address, high)
    end

    # D-Word access with 8-bits memory cases
    def get(%{:sm => sm} = state, operand, [address])
    when operand in [:ID, :QD, :FD, :SD, :PD, :OD]
    do
        base = state |> sm.base(operand)
        abs = address * 4

        b0 = sm.read_memory(state, abs)
        b1 = sm.read_memory(state, abs) <<< 8
        b2 = sm.read_memory(state, abs)
        b3 = sm.read_memory(state, abs) <<< 8

        [b1 + b0, b2 + b3]
    end
    def set(%{:sm => sm} = state, operand, [address], [w0, w1])
    when operand in [:ID, :QD, :FD, :SD, :PD, :OD]
    do
        base = state |> sm.base(operand)
        abs = address * 4

        b0 = w0 &&& 0xFF
        b1 = (w0 &&& 0xFF00) >>> 8
        b2 = w1 &&& 0xFF
        b3 = (w0 &&& 0xFF00) >>> 8

        state 
            |> sm.write_memory(abs, b0)
            |> sm.write_memory(abs, b1)
            |> sm.write_memory(abs, b2)
            |> sm.write_memory(abs, b3)
    end
end

defmodule Emulators.S5.VM do
    @state_manager Emulators.S5.StateManager
    def new() do
        @state_manager.new
    end

    def boot(%{
        :specs => %{
                :ptr => %{
                    :PIQ => piq, 
                    :PII => pii, 
                    :FLAGS => flags, 
                    :TIMERS => timers,
                    :COUNTERS => counters,
                    :RI => ri
                }
            }
        } = state) do

        state 
            |> @state_manager.set(:RS, 12, pii)
            |> @state_manager.set(:RS, 13, piq)
            |> @state_manager.set(:RS, 14, flags)
            |> @state_manager.set(:RS, 15, timers)
            |> @state_manager.set(:RS, 16, counters)
            |> @state_manager.set(:RS, 17, ri)
    end
end