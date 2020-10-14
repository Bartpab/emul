defmodule Emulators.S5.AP.CommonState do
  defmacro __using__(_) do
    quote do
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
              edges: %{
                RLO: :stay
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
            mode: %{
              current: :default,
              prev: :default,
              changed: false
            }
          }
        }
        |> Map.merge(Emulators.State.new())
        |> init()
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
            |> Emulators.Utils.adjust([value], 16, 32)
            |> Enum.fetch!(0)

          :RLO ->
            (state |> get(:CC) &&& 2) >>> 1

          reg ->
            state |> registers |> Map.fetch!(reg)
        end
      end

      def set_edge(state, edge, value) do
        edge =
          case value do
            -1 -> :negative
            1 -> :positive
            0 -> :stay
          end

        put_in(state, [:registers, :edges, edge], edge)
      end

      def get_edge(state, edge) do
        get_in(state, [:registers, :edges, edge])
      end

      def set(state, reg, value) do
        case reg do
          :ACCU_1 ->
            [low, high] = Emulators.Utils.adjust([value], 32, 16)

            state
            |> set(:ACCU_1_L, low)
            |> set(:ACCU_1_H, high)

          :RLO ->
            cc = (get(state, :CC) &&& ~~~0b10) + ((value &&& 1) <<< 1)
            old_rlo = state |> get(:RLO)

            state
            |> set(:CC, cc)
            |> set_edge(:RLO, rlo - old_rlo)

          reg ->
            registers =
              state
              |> registers
              |> Map.put(reg, value)

            state
            |> set_registers(registers)
        end
      end

      # Mode-related functions
      def set_mode(state, mode) do
        prev = get_in(state, [:ap, :mode, :current])

        state
        |> put_in([:ap, :mode, :prev], prev)
        |> put_in([:ap, :mode, :current], mode)
        |> put_in([:ap, :mode, :changed], true)
      end

      def mode(state) do
        get_in(state, [:ap, :mode, :current])
      end

      def has_mode_changed(state) do
        get_in(state, [:ap, :mode, :changed])
      end

      def ack_mode(state) do
        state |> put_in([:ap, :mode, :changed], false)
      end

      def mode_transition(state) do
        {get_in(state, [:ap, :mode, :current]), get_in(state, [:ap, :mode, :prev])}
      end
    end
  end
end
