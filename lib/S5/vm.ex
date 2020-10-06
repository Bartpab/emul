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
