defmodule Emulators.S5.AP.Firmware do  
    alias Emulators.S5.Block
    alias Emulators.S5.AP.State, as: APS
    alias Emulators.S5.AP.Firmware.SpecialFunctions

    def load_blocks(state)
    do
        state |> State.iterate_blocks(
            :USER,
            fn state, block, address, next -> 
                type = block |> Block.type
                id =  block |> Block.id
                state 
                    |> APS.set_block_entry(type, id, address + 6)
                    |> APS.set_block_validity!(type, id, 1)
                    |> next.()
            end
        )
    end

    def init_system_area(state) do
        # Lazy curries
        ptr = fn ptr -> APS.ptr(state, ptr) end
        bptr = fn ptr -> APS.ptr(state, :BLOCK_TABLE)[ptr] end

        state
            |> APS.set(:RS, 12, ptr.(:PII))
            |> APS.set(:RS, 13, ptr.(:PIQ))
            |> APS.set(:RS, 14, ptr.(:FLAGS))
            |> APS.set(:RS, 15, ptr.(:TIMERS))
            |> APS.set(:RS, 16, ptr.(:COUNTERS))
            |> APS.set(:RS, 17, ptr.(:RI))
            |> APS.set(:RS, 32, bptr.(:DX))
            |> APS.set(:RS, 33, bptr.(:FX))
            |> APS.set(:RS, 34, bptr.(:DX))
            |> APS.set(:RS, 35, bptr.(:SB))
            |> APS.set(:RS, 36, bptr.(:PB))
            |> APS.set(:RS, 37, bptr.(:FB))
            |> APS.set(:RS, 38, bptr.(:OB))
    end
    
    def process_interrupt(state, interrupt) do
        case interrupt do
            {:OB, id} -> SpecialFunctions.dispatch(state, id)
        end
    end

    def process_transition(state, transition) do
        case transition do
            {:POWER_ON, _} ->
                state 
                    |> init_system_area
                    |> load_blocks
                    |> APS.set_mode(:STOP)
            _ -> 
                state
        end
    end

    def process_message(state, msg) do
        case msg do
            :POWER_ON -> state |> APS.set_mode(:POWER_ON)
            _-> state
        end
    end

    def frame(state) do
        try do
            {msg, state} = Emulator.State.poll_message(state)
            cond do
                msg != :empty ->
                    state 
                        |> process_message(msg)
                        |> frame

                EmulatorState.has_interrupt(state) ->
                    interrupt = EmulatorState.get_interrupt(state)
                    state 
                         |> process_interrupt(interrupt)
                         |> EmulatorState.clear_interrupt
                
                APS.has_mode_changed(state) ->
                    state
                        |> APS.ack_mode
                        |> process_transition(APS.mode_transition(state)) 

                true -> state
            end         
        rescue
            _ -> state
        end
    end
end