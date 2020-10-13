defmodule Emulators.S5.Guards do
  defguard is_bit(operand) when operand in [:I, :Q, :F]

  defguard is_byte(operand)
           when operand in [
                  :IB,
                  :QB,
                  :FY,
                  :DL,
                  :DR,
                  :PY,
                  :OY
                ]

  defguard is_word(operand)
           when operand in [
                  :IW,
                  :QW,
                  :FW,
                  :DW,
                  :PW,
                  :OW
                ]

  defguard is_dword(operand)
           when operand in [
                  :ID,
                  :QD,
                  :FD,
                  :DD
                ]
end
