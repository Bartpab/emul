defmodule Emulation.S5.AP.CommonState do
  def new() do
    %{
      ap: %{
        registers: %{
          index: %{
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
          },
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
        edges: %{
          RLO: :stay
        },
        # microseconds
        tick: 0,
        # Wait in microseconds
        wait: 0,
        states: [:DEFAULT],
        transitions: []
      }
    }
  end

  defmacro __using__(_) do
    quote do
      def new(state) do
        state
        |> Map.merge(Emulation.S5.AP.CommonState.new())
        |> Emulation.Common.PushdownAutomaton.new([:ap, :mode])
        |> Emulation.Common.PushdownAutomaton.new([:ap, :exe])
        |> init()
      end

      def now(state) do
        state[:ap][:tick]
      end

      def stop(state) do
        state |> Emulation.Emulator.State.push(:STOP)
      end

      # Register-related functions
      def registers(state) do
        get_in(state, [:ap, :registers])
      end

      def set_registers(state, registers) do
        put_in(state, [:ap, :registers], registers)
      end

      def get(state, reg) do
        case reg do
          :ACCU_1 ->
            [state |> get(:ACCU_1_L), state |> get(:ACCU_1_H)]
            |> Emulation.Common.Utils.adjust(16, 32)
            |> Enum.fetch!(0)

          :RLO ->
            (state |> get(:CC) &&& 2) >>> 1

          reg ->
            state |> registers |> Map.fetch!(reg)
        end
      end

      def set_edge(state, edge, value) do
        edge_direction =
          case value do
            -1 -> :falling
            1 -> :raising
            0 -> :stay
          end

        put_in(state, [:ap, :edges, edge], edge_direction)
      end

      def get_edge(state, edge) do
        get_in(state, [:ap, :edges, edge])
      end

      def set(state, reg, value) do
        case reg do
          :ACCU_1 ->
            [low, high] = Emulation.Common.Utils.adjust([value], 32, 16)

            state
            |> set(:ACCU_1_L, low)
            |> set(:ACCU_1_H, high)

          :RLO ->
            cc = (get(state, :CC) &&& ~~~0b10) + ((value &&& 1) <<< 1)

            state
            |> set(:CC, cc)

          reg ->
            registers =
              state
              |> registers
              |> Map.put(reg, value)

            state
            |> set_registers(registers)
        end
      end
    end
  end
end
