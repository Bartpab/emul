defmodule Emulators.S5.AP.Firmware do
    alias Emulators.S5.Block
    alias Emulators.S5.AP.State, as: APS
    alias Emulators.S5.AP.Firmware.SpecialFunctions

    def call_special_function(state, ob_id) do
        SpecialFunctions.dispatch(state, ob_id)
    end
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
end
