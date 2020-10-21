defmodule Emulation.S5.AP.State.Utils do
  defmacro __using__(_) do
    quote do
      defguard is_constant(operand)
               when operand in [
                      :DH,
                      :KB,
                      :KC,
                      :KF,
                      :KG,
                      :KH,
                      :KM,
                      :KS,
                      :KT,
                      :KY
                    ]

      def op2area(operand) do
        cond do
          operand in [:Q, :QB, :QW, :QD] -> :PIQ
          operand in [:I, :IB, :IW, :ID] -> :PII
          operand in [:C] -> :C
          operand in [:T] -> :T
          operand in [:PY, :PW] -> :P
          operand in [:OY, :OW] -> :O
          operand in [:F, :FY, :FW, :FD] -> :F
          operand in [:S, :SY, :SW, :SD] -> :S
          operand in [:DR, :DL, :DW, :DD] -> :D
        end
      end

      def op2shift(operand) do
        case operand do
          :DL -> 8
          _ -> 0
        end
      end

      def get_cell_size(area) do
        case area do
          :PIQ -> 8
          :PII -> 8
          :P -> 8
          :O -> 8
          :F -> 8
          :S -> 8
          :D -> 16
          :C -> 16
          :T -> 16
        end
      end

      def get_data_size(operand) do
        cond do
          operand in [:Q, :I, :F, :S] -> 1
          operand in [:QB, :IB, :PY, :OY, :FY, :SY, :DR, :DL] -> 8
          operand in [:QW, :IW, :PW, :OW, :FW, :SW, :DW, :C, :T] -> 16
          operand in [:QD, :ID, :FD, :SD, :DD] -> 32
        end
      end
    end
  end
end
