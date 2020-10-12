defmodule Emulators.S5.AP do
    use Emulators.Device

    alias Emulators.S5.AP.State
    alias Emulators.S5.AP.Firmware

    def start(_) do
        State.new
            |> Map.merge(ES.new)
    end

    def init(state) do
        state |> APS.set_mode(:POWER_OFF)
    end

    def process_interrupt(state, interrupt) do
        case interrupt do
            {:OB, id} -> Firmware.call_special_function(state, id)
        end
    end

    def process_transition(state, transition) do
        case transition do
            {:POWER_OFF, _} ->
                state
                    |> Device.set_mode(:IDLE)
            {:POWER_ON, _} ->
                state
                    |> Firmware.init_system_area
                    |> Firmware.load_blocks
                    |> APS.set_mode(:STOP)
            {:STOP, _} ->
                state
                    |> Device.set_mode(:IDLE)
            {:RUN, _} ->
                state
                    |> Device.set_mode(:RUN)
            _ ->
                state
        end
    end

    def process_message(state, msg, _from) do
        case msg do
            :POWER_ON -> state |> APS.set_mode(:POWER_ON)
            _-> state
        end
    end

    def frame(state) do
        state = state |> Emulators.COM.dispatch(&process_message/3)
        try do
            cond do
                ES.has_interrupt(state) ->
                    interrupt = ES.get_interrupt(state)
                    state
                         |> process_interrupt(interrupt)
                         |> ES.clear_interrupt

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
