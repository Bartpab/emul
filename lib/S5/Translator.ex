defmodule Emulators.S5.Translator do
  use Bitwise

  def translate([w0 | _]) when (w0 >>> 8) == 0xB8 do
    {2, :A, :C, [w0 &&& 0x00FF]}
  end
  def translate([0x783F | [w1 | _]]) when (w1 >>> 12) == 0x00 do
    {2, :A, :D, [(w1 &&& 0x0F00) >>> 8, w1 &&& 0x00FF]}
  end
  def translate([w0 | _]) when w0 >>> 12 == 0xC do
    {1, :A, :I_Q, [(w0 &&& 0x0F00) >>> 8, w0 &&& 0x00FF]}
  end
  def translate([w0 | _]) when (w0 >>> 12) == 0x8 do
    {1, :A, :F, [(w0 &&& 0x0F00) >>> 8, w0 &&& 0x00FF]}
  end
  def translate([0x780B | [w1 | _]]) do
    {2, :A, :S, [(w1 &&& 0xF000) >>> 12, w1 &&& 0x0FFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0xF8 do
    {1, :A, :T, [w0 &&& 0xFF]}
  end
  def translate([0xBA00 | _]) do
    {1, :A_lpar, :no_operand, []}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x07 do
    {1, :A_assign, :formal_operand, [w0 &&& 0xFF]}
  end
  def translate([0x780A | [w1 | _]]) do
    {2, :ABR, :constant, [w1]}
  end
  def translate([0x783D | _]) do
    {1, :ACR, :no_operand, []}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x50 do
    {1, :ADD, :BN, [w0 &&& 0xFF]}
  end
  def translate([0x6005 | [w1 | [w2 | _]]]) do
    {3, :ADD, :DH, [w1, w2]}
  end
  def translate([0x5800 | [w1 | _]]) do
    {2, :ADD, :KF, [w1]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0xBC do
    {1, :AN, :C, [w0 &&& 0xFF]}
  end
  def translate([0x783F | [w1 | _]]) when (w1 >>> 12) == 0x4 do
    {2, :AN, :D, [(0x0F00 &&& w1) >>> 8, (0xFF &&& w1)]}
  end
  def translate([w0 | _]) when (w0 >>> 12) == 0xA do
    {1, :AN, :F, [(0x0F00 &&& w0) >>> 8, (0xFF &&& w0)]}
  end
  def translate([w0 | _]) when (w0 >>> 12) == 0xE do
    {1, :AN, :I_Q, [(0x0F00 &&& w0) >>> 8, (0xFF &&& w0)]}
  end
  def translate([0x784B | [w1 | _]]) do
    {2, :AN, :S, [w1 >>> 12, w1 &&& 0xFFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0xFC do
    {1, :AN, :T, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x27 do
    {1, :AN_assign, :formal_operand, [w0 &&& 0xFF]}
  end
  def translate([0x4100 | _]) do
    {1, :AW, :no_operand, []}
  end
  def translate([0xFE00 | _]) do
    {1, :BAF, :no_operand, []}
  end
  def translate([0xBE00 | _]) do
    {1, :BAS, :no_operand, []}
  end
  def translate([0x6500 | _]) do
    {1, :BE, :no_operand, []}
  end
  def translate([0x0500 | _]) do
    {1, :BEC, :no_operand, []}
  end
  def translate([0x6501 | _]) do
    {1, :BEU, :no_operand, []}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x10 do
    {1, :BLD, :constant, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x20 do
    {1, :C, :DB, [0xFF &&& w0]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x54 do
    {1, :CD, :C, [0xFF &&& w0]}
  end
  def translate([0x0100 | _]) do
    {1, :CFW, :no_operand, []}
  end
  def translate([0x6807 | _]) do
    {1, :CSD, :no_operand, []}
  end
  def translate([0x0900 | _]) do
    {1, :CSW, :no_operand, []}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x6C do
    {1, :CU, :C, [0xFF &&& w0]}
  end
  def translate([0x7803 | [w1 | _]]) when (w1 >>> 8) == 0x11 do
    {2, :CX, :DX, [0xFF &&& w1]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x19 do
    {1, :D, :constant, [w0 &&& 0xFF]}
  end
  def translate([0x680E | _]) do
    {1, :DED, :no_operand, []}
  end
  def translate([0x680C | _]) do
    {1, :DEF, :no_operand, []}
  end
  def translate([0x7E00 | _]) do
    {1, :DI, :no_operand, []}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x6E do
    {1, :DO, :DW, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x4E do
    {1, :DO, :FW, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x18 do
    {1, :DO, :RS, [w0 &&& 0xFF]}
  end
  def translate([w0| _ ]) when (w0 >>> 8) == 0x76 do
    {1, :DO_assign, :formal_operand, [w0 &&& 0xFF]}
  end
  def translate([0x7802 | [w1 | _]]) when (w1 >>> 8) == 0x09 do
    {2, :DOC, :FX, [0xFF &&& w1]}
  end
  def translate([0x7801 | [w1 | _]]) when (w1 >>> 8) == 0x01 do
    {2, :DOU, :FX, [0xFF &&& w1]}
  end
  def translate([0x680A | _]) do
    {1, :DUD, :no_operand, []}
  end
  def translate([0x6808 | _]) do
    {1, :DUF, :no_operand, []}
  end
  def translate([0x6008 | _]) do
    {1, :ENT, :no_operand, []}
  end
  def translate([0x6806 | _]) do
    {1, :FDG, :no_operand, []}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x44 do
    {1, :FR, :C, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x04 do
    {1, :FR, :T, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x06 do
    {1, :FR_assign, :formal_operand, [w0 &&& 0xFF]}
  end
  def translate([0x7805 | [w1 | _]]) when (w1 >>> 8) == 0x00 do
    {2, :G, :DB, [0xFF &&& w1]}
  end
  def translate([0x6802 | _]) do
    {1, :GFD, :no_operand, []}
  end
  def translate([0x7804 | [w1 | _]]) when (w1 >>> 8) == 0x00 do
    {2, :GX, :DX, [w1 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x11 do
    {1, :I, :constant, [0xFF &&& w0]}
  end
  def translate([0x0800 | _]) do
    {1, :IA, :no_operand, []}
  end
  def translate([0x7800 | _]) do
    {1, :IAE, :no_operand, []}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x1D do
    {1, :JC, :FB, [0xFF &&& w0]}
  end
  def translate([w0 |_ ]) when (w0 >>> 8) == 0x4D do
    {1, :JC, :OB, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x55 do
    {1, :JC, :PB, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x5D do
    {1, :JC, :SB, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0xFA do
    {1, :JC_assign, :symbol_address, [0xFF &&& w0]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x25 do
    {1, :JM_assign, :symbol_address, [0xFF &&& w0]}
  end
  def translate([w0 |  _]) when (w0 >>> 8) == 0x35 do
    {1, :JN_assign, :symbol_addrress, [0xFF &&& w0]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x0D do
    {1, :JD_assign, :symbol_address, [0xFF &&& w0]}
  end
  def translate([0x600C | [w1 | _]]) when (w1 >>> 8) == 0x00 do
    {2, :JOS_assign, :symbol_address, [0xFF &&& w1]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x15 do
    {1, :JP_assign, :symbol_address, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x3D do
    {1, :JU, :FB, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x6D do
    {1, :JU, :OB, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x75 do
    {1, :JU, :PB, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x7D do
    {1, :JU, :SB, [w0 &&& 0xFF]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x2D do
    {1, :JU_assign, :symbol_address, [w0 &&& 0xFF]}
  end
  def translate([0x700B | [w1 | _]]) do
    {2, :JUR, :constant, [w1]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x45 do
    {1, :JZ_assign, :symbol_address, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when (w0 >>> 8) == 0x42 do
    {1, :L, :C, [0xFF &&& w0]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x3A do
    {1, :L, :DD, [0xFF &&& w0]}
  end
  def translate([0x3840 | [w1 | [w2 | _]]]) do
    {3, :L, :DH, [w1, w2]}
  end
  def translate([w0 | _]) when (w0 >>> 8) == 0x22 do
    {1, :L, :DL, [w0 &&& 0xFF]}
  end
  def translate([w0 |_]) when (w0 >>> 8) == 0x2A do
    {1, :L, :DR, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x32 do
    {1, :L, :DW, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x1A do
    {1, :L, :FD, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x12 do
    {1, :L, :FW, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x0A do
    {1, :L, :FY, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x4A do
    {1, :L, :IB, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x5A do
    {1, :L, :ID, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x52 do
    {1, :L, :IW, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x28 do
    {1, :L, :KB, [w0 &&& 0xFF]}
  end
  def translate([0x3001|[w1|_]]) do
    {2, :L, :KC, [w1]}
  end
  def translate([0x3004|[w1|_]]) do
    {2, :L, :KF, [w1]}
  end
  def translate([0x3800|[w1|[w2|_]]]) do
    {3, :L, :KG, [w1, w2]}
  end
  def translate([0x3040|[w1|_]]) do
    {2, :L, :KH, [w1]}
  end
  def translate([0x3080|[w1|_]]) do
    {2, :L, :KM, [w1]}
  end
  def translate([0x3010|[w1|_]]) do
    {2, :L, :KS, [w1]}
  end
  def translate([0x3002|[w1|_]]) do
    {2, :L, :KT, [w1]}
  end
  def translate([0x3020|[w1|_]]) do
    {2, :L, :KY, [w1]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x57 do
    {1, :L, :OW, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x5F do
    {1, :L, :OY, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x7A do
    {1, :L, :PW, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x72 do
    {1, :L, :PY, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x4A do
    {1, :L, :QB, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x5A do
    {1, :L, :QD, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x52 do
    {1, :L, :QW, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x6A do
    {1, :L, :RI, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x47 do
    {1, :L, :RJ, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x62 do
    {1, :L, :RS, [w0 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x4F do
    {1, :L, :RT, [w0 &&& 0xFF]}
  end
  def translate([0x78EB|[w1|_]]) when (w1 >>> 12) == 0x00 do
    {2, :L, :SD, [(w1 &&& 0x0F00) >>> 8, w1 &&& 0xFF]}
  end
  def translate([0x78CB|[w1|_]]) when (w1 >>> 12) == 0x00 do
    {2, :L, :SW, [(w1 &&& 0x0F00) >>> 8, w1 &&& 0xFF]}
  end
  def translate([0x78AB|[w1|_]]) when (w1 >>> 12) == 0x00 do
    {2, :L, :SY, [(w1 &&& 0x0F00) >>> 8, w1 &&& 0xFF]}
  end
  def translate([w0|_]) when (w0 >>> 8) == 0x02 do
    {1, :L, :T, [w0 &&& 0xFF]}
  end
end
