
defmodule Emulators.S5.Firmware do
    use Emulators.S5.Block

    def load_blocks(state):
    do
        state |> State.iterate_blocks(
            :USER,
            fn state, block, address, next -> 
                type = block[:type]
                size = block[:size]
                id = block[:id]
                state 
                    |> State.set_block_entry(type, id, address + 6)
                    |> State.set_block_validity!(type, id, 1)
                    |> next()
            end
        )
    end
 
    def process(%{:mode => :RUN} = state)
    do
    end
    
    def process(%{:mode => :RESTART} = state)
    do
    end

    def process(%{:mode => :POWER_ON} = state)
    do
        state |> State.change_mode(:OVERALL_RESET)
    end

    def process(%{
        :mode => :OVERALL_RESET
        :specs => %{
            :ptr => %{
                :DB0 => db0,
                :PIQ => piq,
                :PII => pii,
                :FLAGS => flags,
                :TIMERS => timers,
                :COUNTERS => counters,
                :RI => ri,
                :BLOCK_TABLE => btable
            }
        }    
    } = state)
    do  
        state
            |> State.set(:RS, 12, pii)
            |> State.set(:RS, 13, piq)
            |> State.set(:RS, 14, flags)
            |> State.set(:RS, 15, timers)
            |> State.set(:RS, 16, counters)
            |> State.set(:RS, 17, ri)
            |> State.set(:RS, 32, btable[:DX])
            |> State.set(:RS, 33, btable[:FX])
            |> State.set(:RS, 34, btable[:DX])
            |> State.set(:RS, 35, btable[:SB])
            |> State.set(:RS, 36, btable[:PB])
            |> State.set(:RS, 37, btable[:FB])
            |> State.set(:RS, 38, btable[:OB])
            |> load_blocks
            |> State.set_mode(:STOP)
    end

    
    def process(%{:mode => :POWER_OFF} = state)
    do
        state
    end
end

defmodule Emulators.S5.AS do
    alias Emulators.S5.State
    alias Emulators.S5.Firmware
    alias Emulators.S5.Translator

    def new() do
        State.new
    end

    def power_on(state)
    do
        state |> State.set_mode(:POWER_ON)
    end

    def run(state)
    do
        state |> Firmware.process
    end
end
