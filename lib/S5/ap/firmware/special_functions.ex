defmodule Emulators.S5.AP.Firmware.SpecialFunctions do
    def dispatch(state, _id) do
        state
    end

    # OB 110
    def access_status(state) do
        state
    end

    # OB 112
    def clear_accumulators(state) do
        state
    end

    # OB 112
    def accumulator_roll_up(state) do
        state
    end

    # OB 113
    def accumulator_roll_down(state) do
        state
    end

    # OB 120
    def switch_all_interrupts(state) do
        state
    end

    # OB 121
    def switch_individual_time_interrupts(state) do
        state
    end
    
    # OB 122
    def switch_delay_all_interrupts(state) do
        state
    end

    # OB150
    def get_set_time_for_clock_controlled_time_intterupt(state) do
        state
    end

    # OB 152
end


