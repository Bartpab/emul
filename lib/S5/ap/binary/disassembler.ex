defmodule Emulators.S5.AP.Disassembler do
  use Bitwise

  def translate([w0 | _]) when w0 >>> 8 == 0xB8 do
    {2, :A, :C, [w0 &&& 0x00FF]}
  end

  def translate([0x783F | [w1 | _]]) when w1 >>> 12 == 0x00 do
    {2, :A, :D, [(w1 &&& 0x0F00) >>> 8, w1 &&& 0x00FF]}
  end

  def translate([w0 | _]) when w0 >>> 12 == 0xC do
    addr = w0 &&& 0x00FF
    bit = (w0 &&& 0x0F00) >>> 8

    cond do
      addr < 0x80 -> {1, :A, :I, [bit, addr]}
      addr >= 0x80 -> {1, :A, :Q, [bit, addr - 0x80]}
    end
  end

  def translate([w0 | _]) when w0 >>> 12 == 0x8 do
    {1, :A, :F, [(w0 &&& 0x0F00) >>> 8, w0 &&& 0x00FF]}
  end

  def translate([0x780B | [w1 | _]]) do
    {2, :A, :S, [(w1 &&& 0xF000) >>> 12, w1 &&& 0x0FFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0xF8 do
    {1, :A, :T, [w0 &&& 0xFF]}
  end

  def translate([0xBA00 | _]) do
    {1, :A_lpar, :no_operand, []}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x07 do
    {1, :A_assign, :formal_operand, [w0 &&& 0xFF]}
  end

  def translate([0x780A | [w1 | _]]) do
    {2, :ABR, :constant, [w1]}
  end

  def translate([0x783D | _]) do
    {1, :ACR, :no_operand, []}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x50 do
    {1, :ADD, :BN, [w0 &&& 0xFF]}
  end

  def translate([0x6005 | [w1 | [w2 | _]]]) do
    {3, :ADD, :DH, [w1, w2]}
  end

  def translate([0x5800 | [w1 | _]]) do
    {2, :ADD, :KF, [w1]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0xBC do
    {1, :AN, :C, [w0 &&& 0xFF]}
  end

  def translate([0x783F | [w1 | _]]) when w1 >>> 12 == 0x4 do
    {2, :AN, :D, [(0x0F00 &&& w1) >>> 8, 0xFF &&& w1]}
  end

  def translate([w0 | _]) when w0 >>> 12 == 0xA do
    {1, :AN, :F, [(0x0F00 &&& w0) >>> 8, 0xFF &&& w0]}
  end

  def translate([w0 | _]) when w0 >>> 12 == 0xE do
    addr = w0 &&& 0x00FF
    bit = (w0 &&& 0x0F00) >>> 8

    cond do
      addr < 0x80 -> {1, :AN, :I, [bit, addr]}
      addr >= 0x80 -> {1, :AN, :Q, [bit, addr - 0x80]}
    end
  end

  def translate([0x784B | [w1 | _]]) do
    {2, :AN, :S, [w1 >>> 12, w1 &&& 0xFFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0xFC do
    {1, :AN, :T, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x27 do
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

  def translate([w0 | _]) when w0 >>> 8 == 0x10 do
    {1, :BLD, :constant, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x20 do
    {1, :C, :DB, [0xFF &&& w0]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x54 do
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

  def translate([w0 | _]) when w0 >>> 8 == 0x6C do
    {1, :CU, :C, [0xFF &&& w0]}
  end

  def translate([0x7803 | [w1 | _]]) when w1 >>> 8 == 0x11 do
    {2, :CX, :DX, [0xFF &&& w1]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x19 do
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

  def translate([w0 | _]) when w0 >>> 8 == 0x6E do
    {1, :DO, :DW, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x4E do
    {1, :DO, :FW, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x18 do
    {1, :DO, :RS, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x76 do
    {1, :DO_assign, :formal_operand, [w0 &&& 0xFF]}
  end

  def translate([0x7802 | [w1 | _]]) when w1 >>> 8 == 0x09 do
    {2, :DOC, :FX, [0xFF &&& w1]}
  end

  def translate([0x7801 | [w1 | _]]) when w1 >>> 8 == 0x01 do
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

  def translate([w0 | _]) when w0 >>> 8 == 0x44 do
    {1, :FR, :C, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x04 do
    {1, :FR, :T, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x06 do
    {1, :FR_assign, :formal_operand, [w0 &&& 0xFF]}
  end

  def translate([0x7805 | [w1 | _]]) when w1 >>> 8 == 0x00 do
    {2, :G, :DB, [0xFF &&& w1]}
  end

  def translate([0x6802 | _]) do
    {1, :GFD, :no_operand, []}
  end

  def translate([0x7804 | [w1 | _]]) when w1 >>> 8 == 0x00 do
    {2, :GX, :DX, [w1 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x11 do
    {1, :I, :constant, [0xFF &&& w0]}
  end

  def translate([0x0800 | _]) do
    {1, :IA, :no_operand, []}
  end

  def translate([0x7800 | _]) do
    {1, :IAE, :no_operand, []}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x1D do
    {1, :JC, :FB, [0xFF &&& w0]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x4D do
    {1, :JC, :OB, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x55 do
    {1, :JC, :PB, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x5D do
    {1, :JC, :SB, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0xFA do
    {1, :JC_assign, :symbol_address, [0xFF &&& w0]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x25 do
    {1, :JM_assign, :symbol_address, [0xFF &&& w0]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x35 do
    {1, :JN_assign, :symbol_addrress, [0xFF &&& w0]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x0D do
    {1, :JD_assign, :symbol_address, [0xFF &&& w0]}
  end

  def translate([0x600C | [w1 | _]]) when w1 >>> 8 == 0x00 do
    {2, :JOS_assign, :symbol_address, [0xFF &&& w1]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x15 do
    {1, :JP_assign, :symbol_address, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x3D do
    {1, :JU, :FB, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x6D do
    {1, :JU, :OB, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x75 do
    {1, :JU, :PB, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x7D do
    {1, :JU, :SB, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x2D do
    {1, :JU_assign, :symbol_address, [w0 &&& 0xFF]}
  end

  def translate([0x700B | [w1 | _]]) do
    {2, :JUR, :constant, [w1]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x45 do
    {1, :JZ_assign, :symbol_address, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x42 do
    {1, :L, :C, [0xFF &&& w0]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x3A do
    {1, :L, :DD, [0xFF &&& w0]}
  end

  def translate([0x3840 | [w1 | [w2 | _]]]) do
    {3, :L, :DH, [w1, w2]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x22 do
    {1, :L, :DL, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x2A do
    {1, :L, :DR, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x32 do
    {1, :L, :DW, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x1A do
    {1, :L, :FD, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x12 do
    {1, :L, :FW, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x0A do
    {1, :L, :FY, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x4A do
    {1, :L, :IB, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x5A do
    {1, :L, :ID, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x52 do
    {1, :L, :IW, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x28 do
    {1, :L, :KB, [w0 &&& 0xFF]}
  end

  def translate([0x3001 | [w1 | _]]) do
    {2, :L, :KC, [w1]}
  end

  def translate([0x3004 | [w1 | _]]) do
    {2, :L, :KF, [w1]}
  end

  def translate([0x3800 | [w1 | [w2 | _]]]) do
    {3, :L, :KG, [w1, w2]}
  end

  def translate([0x3040 | [w1 | _]]) do
    {2, :L, :KH, [w1]}
  end

  def translate([0x3080 | [w1 | _]]) do
    {2, :L, :KM, [w1]}
  end

  def translate([0x3010 | [w1 | _]]) do
    {2, :L, :KS, [w1]}
  end

  def translate([0x3002 | [w1 | _]]) do
    {2, :L, :KT, [w1]}
  end

  def translate([0x3020 | [w1 | _]]) do
    {2, :L, :KY, [w1]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x57 do
    {1, :L, :OW, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x5F do
    {1, :L, :OY, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x7A do
    {1, :L, :PW, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x72 do
    {1, :L, :PY, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x4A do
    {1, :L, :QB, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x5A do
    {1, :L, :QD, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x52 do
    {1, :L, :QW, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x6A do
    {1, :L, :RI, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x47 do
    {1, :L, :RJ, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x62 do
    {1, :L, :RS, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x4F do
    {1, :L, :RT, [w0 &&& 0xFF]}
  end

  def translate([0x78EB | [w1 | _]]) when w1 >>> 12 == 0x00 do
    {2, :L, :SD, [(w1 &&& 0x0F00) >>> 8, w1 &&& 0xFF]}
  end

  def translate([0x78CB | [w1 | _]]) when w1 >>> 12 == 0x00 do
    {2, :L, :SW, [(w1 &&& 0x0F00) >>> 8, w1 &&& 0xFF]}
  end

  def translate([0x78AB | [w1 | _]]) when w1 >>> 12 == 0x00 do
    {2, :L, :SY, [(w1 &&& 0x0F00) >>> 8, w1 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x02 do
    {1, :L, :T, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x46 do
    {1, :L_assign, :formal_operand, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x4C do
    {1, :LC, :C, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x0C do
    {1, :LC, :T, [w0 &&& 0xFF]}
  end

  def translate([0x680B | _]) do
    {1, :LDI, :A1, []}
  end

  def translate([0x682B | _]) do
    {1, :LDI, :A2, []}
  end

  def translate([0x689B | _]) do
    {1, :LDI, :BA, []}
  end

  def translate([0x68AB | _]) do
    {1, :LDI, :BR, []}
  end

  def translate([0x684B | _]) do
    {1, :LDI, :SA, []}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x0E do
    {1, :LD_assign, :formal_operand, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x56 do
    {1, :LDW_assign, :formal_operand, [w0 &&& 0xFF]}
  end

  def translate([0x700C | _]) do
    {1, :LIM, :no_operand, []}
  end

  def translate([w0 | _]) when w0 >>> 4 == 0x400 do
    {1, :LIR, :register_number, [0xF &&& w0]}
  end

  def translate([0x6804 | [w1 | _]]) do
    {2, :LRD, :constant, [w1]}
  end

  def translate([0x6800 | [w1 | _]]) do
    {2, :LRW, :constant, [w1]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x3F do
    {1, :LW_assign, :formal_operand, [w0]}
  end

  def translate([0x786D | [w1 | _]]) do
    {2, :LW_CD, :constant, [w1]}
  end

  def translate([0x785D | [w1 | _]]) do
    {2, :LW_CW, :constant, [w1]}
  end

  def translate([0x786E | [w1 | _]]) do
    {2, :LW_GD, :constant, [w1]}
  end

  def translate([0x785E | [w1 | _]]) do
    {2, :LW_GW, :constant, [w1]}
  end

  def translate([0x780D, [w1 | _]]) do
    {2, :LY_CB, :constant, [w1]}
  end

  def translate([0x782D, [w1 | _]]) do
    {2, :LY_CD, :constant, [w1]}
  end

  def translate([0x781D, [w1 | _]]) do
    {2, :LY_CW, :constant, [w1]}
  end

  def translate([0x780E, [w1 | _]]) do
    {2, :LY_GB, :constant, [w1]}
  end

  def translate([0x782E, [w1 | _]]) do
    {2, :LY_GD, :constant, [w1]}
  end

  def translate([0x781E, [w1 | _]]) do
    {2, :LY_GW, :constant, [w1]}
  end

  def translate([0x6829 | _]) do
    {1, :MAB, :no_operand, []}
  end

  def translate([0x6819 | _]) do
    {1, :MAS, :no_operand, []}
  end

  def translate([0x6889 | _]) do
    {1, :MBA, :no_operand, []}
  end

  def translate([w0 | [w1 | _]]) when w0 >>> 8 == 0x78 and (w0 &&& 0xF) == 0x09 do
    {2, :MBR, :constant, [w0 >>> 4 &&& 0xFF, w1]}
  end

  def translate([0x6899 | _]) do
    {1, :MBS, :no_operand, []}
  end

  def translate([0x6849 | _]) do
    {1, :MSA, :no_operand, []}
  end

  def translate([0x6869 | _]) do
    {1, :MSB, :no_operand, []}
  end

  def translate([0x0000 | _]) do
    {1, :NOP_0, :no_operand, []}
  end

  def translate([0xFFFF | _]) do
    {1, :NOP_1, :no_operand, []}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0xB9 do
    {1, :O, :C, [w0 &&& 0xFF]}
  end

  def translate([0x783F | [w1 | _]]) when w1 >>> 12 == 0x1 do
    bit = w1 >>> 8 &&& 0x0F
    addr = w1 &&& 0xFF
    {2, :O, :D, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 12 == 0x8 and (w0 >>> 8 &&& 0x0F) >= 0x8 do
    bit = (w0 >>> 8 &&& 0x0F) - 0x8
    addr = w0 &&& 0xFF
    {1, :O, :F, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 12 == 0xC and (w0 >>> 8 &&& 0x0F) >= 0x8 do
    bit = (w0 >>> 8 &&& 0xF) - 0x8
    addr = w0 &&& 0xFF

    cond do
      addr < 0x80 -> {1, :O, :I, [bit, addr]}
      addr >= 0x80 -> {1, :O, :Q, [bit, addr - 0x80]}
    end
  end

  def translate([0x781B, [w1 | _]]) do
    bit = w1 >>> 12
    addr = w1 &&& 0xFFF
    {2, :O, :S, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0xF9 do
    {1, :O, :T, [w0 &&& 0xFF]}
  end

  def translate([0xFB00 | _]) do
    {1, :O, :no_operand, []}
  end

  def translate([0xBB00 | _]) do
    {1, :O_lpar, :no_operand, []}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x0F do
    {1, :O_assign, :formal_operand, [w0 &&& 0xFF]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0xBD do
    {1, :ON, :C, [0xFF &&& w0]}
  end

  def translate([0x783F | [w1 | _]]) when w1 >>> 12 == 0x3 do
    bit = w1 >>> 8 &&& 0x0F
    addr = w1 &&& 0xFF
    {2, :ON, :D, [bit, addr]}
  end

  def translate([w0 | _])
      when w0 >>> 12 == 0xA and
             (w0 >>> 8 &&& 0xF) >= 0x8 do
    bit = (w0 >>> 8 &&& 0x0F) - 0x8
    addr = w0 &&& 0xFF
    {1, :ON, :F, [bit, addr]}
  end

  def translate([w0 | _])
      when w0 >>> 12 == 0xE and
             (w0 >>> 8 &&& 0xF) >= 0x8 do
    bit = (w0 >>> 8 &&& 0x0F) - 0x8
    addr = w0 &&& 0xFF

    cond do
      addr < 0x80 -> {1, :ON, :I, [bit, addr]}
      addr >= 0x80 -> {1, :ON, :Q, [bit, addr - 0x80]}
    end
  end

  def translate([0x785B | [w1 | _]]) do
    bit = w1 >>> 12
    addr = w1 &&& 0xFFF
    {1, :ON, :S, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0xFD do
    addr = w0 &&& 0xFF
    {1, :ON, :T, [addr]}
  end

  def translate([0x0880 | _]) do
    {1, :RA, :no_operand, []}
  end

  def translate([0x7810 | _]) do
    {1, :RAE, :no_operand, []}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x37 do
    value = w0 &&& 0xFF
    {1, :RB_assign, :formal_operand, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x3E do
    value = w0 &&& 0xFF
    {1, :RD_assign, :formal_operand, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x64 do
    value = w0 &&& 0xFF
    {1, :RLD, :constant, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x74 do
    addr = w0 &&& 0xFF
    {1, :RRD, :constant, [addr]}
  end

  def translate([0x7015 | [w1 | _]]) when w1 >>> 12 == 0x0 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :RU, :C, [bit, addr]}
  end

  def translate([0x7046 | [w1 | _]]) when w1 >>> 12 == 0x0 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :RU, :D, [bit, addr]}
  end

  def translate([0x7049 | [w1 | _]]) when w1 >>> 12 == 0x0 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :RU, :F, [bit, addr]}
  end

  def translate([0x7038 | [w1 | _]]) when w1 >>> 12 == 0x0 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF

    cond do
      addr < 0x80 -> {1, :RU, :I, [bit, addr]}
      addr >= 0x80 -> {1, :RU, :I, [bit, addr - 0x80]}
    end
  end

  def translate([0x7047 | [w1 | _]]) when w1 >>> 12 == 0x0 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :RU, :RI, [bit, addr]}
  end

  def translate([0x701E | [w1 | _]]) when w1 >>> 12 == 0x0 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :RU, :RJ, [bit, addr]}
  end

  def translate([0x7057 | [w1 | _]]) when w1 >>> 12 == 0x0 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :RU, :RS, [bit, addr]}
  end

  def translate([0x700E | [w1 | _]]) when w1 >>> 12 == 0x0 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :RU, :RT, [bit, addr]}
  end

  def translate([0x7025 | [w1 | _]]) when w1 >>> 12 == 0x0 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :RU, :T, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x5C do
    {1, :S, :C, [0xFF &&& w0]}
  end

  def translate([0x783F | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :S, :D, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 12 == 0x9 do
    bit = w0 >>> 8 &&& 0xF
    addr = w0 &&& 0xFF
    {1, :S, :F, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 12 == 0xD do
    bit = w0 >>> 8 &&& 0xF
    addr = w0 &&& 0xFF

    cond do
      addr < 0x80 -> {1, :S, :I, [bit, addr]}
      addr >= 0x80 -> {1, :S, :Q, [bit, addr - 0x80]}
    end
  end

  def translate([0x782B | [w1 | _]]) do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFFF
    {2, :S, :S, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x17 do
    value = w0 &&& 0xFF
    {1, :S_assign, :formal_operand, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x24 do
    addr = w0 &&& 0xFF
    {1, :SD, :T, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x26 do
    addr = w0 &&& 0xFF
    {1, :SD_assign, :formal_operand, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x1C do
    addr = w0 &&& 0xFF
    {1, :SE, :T, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x1E do
    addr = w0 &&& 0xFF
    {1, :SEC_assign, :formal_operand, [addr]}
  end

  def translate([0x7806 | [w1 | _]]) when w1 >>> 8 == 0x00 do
    value = w1 &&& 0xFF
    {2, :SED, :constant, [value]}
  end

  def translate([0x7807 | [w1 | _]]) when w1 >>> 8 == 0x00 do
    value = w1 &&& 0xFF
    {2, :SEE, :constant, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x14 do
    value = w0 &&& 0xFF
    {1, :SF, :T, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x16 do
    value = w0 &&& 0xFF
    {1, :SFD_assign, :formal_operand, [value]}
  end

  def translate([0x700D | _]) do
    {1, :SIM, :no_operand, []}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x29 do
    value = w0 &&& 0xFF
    {1, :SLD, :constant, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x61 do
    value = w0 &&& 0xFF
    {1, :SLW, :constant, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x34 do
    value = w0 &&& 0xFF
    {1, :SP, :T, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x36 do
    value = w0 &&& 0xFF
    {1, :SP_assign, :formal_operand, [value]}
  end

  def translate([w0 | _]) when w0 >>> 4 == 0x690 do
    value = w0 &&& 0xF
    {1, :SRW, :constant, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x2C do
    value = w0 &&& 0xFF
    {1, :SS, :T, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x71 do
    value = w0 &&& 0xFF
    {1, :SSD, :constant, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x2E do
    value = w0 &&& 0xFF
    {1, :SSU_assign, :formal_operand, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x68 and (w0 &&& 0xF) == 0x1 do
    value = w0 >>> 4 &&& 0xF
    {1, :SSW, :constant, [value]}
  end

  def translate([0x7003 | _]) do
    {1, :STP, :no_operand, []}
  end

  def translate([0x7000 | _]) do
    {1, :STS, :no_operand, []}
  end

  def translate([0x7004 | _]) do
    {1, :STW, :no_operand, []}
  end

  def translate([0x7015 | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :SU, :C, [bit, addr]}
  end

  def translate([0x7046 | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :SU, :D, [bit, addr]}
  end

  def translate([0x7049 | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :SU, :F, [bit, addr]}
  end

  def translate([0x7038 | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :SU, :F, [bit, addr]}
  end

  def translate([0x7038 | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF

    cond do
      addr < 0x80 -> {2, :SU, :I, [bit, addr]}
      addr >= 0x80 -> {2, :SU, :Q, [bit, addr]}
    end
  end

  def translate([0x7047 | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :SU, :RI, [bit, addr]}
  end

  def translate([0x701E | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :SU, :RJ, [bit, addr]}
  end

  def translate([0x7057 | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :SU, :RS, [bit, addr]}
  end

  def translate([0x700E | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :SU, :RT, [bit, addr]}
  end

  def translate([0x7025 | [w1 | _]]) when w1 >>> 12 == 0x4 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :SU, :T, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x3B do
    addr = w0 &&& 0xFF
    {1, :T, :DD, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x23 do
    addr = w0 &&& 0xFF
    {1, :T, :DL, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x2B do
    addr = w0 &&& 0xFF
    {1, :T, :DR, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x33 do
    addr = w0 &&& 0xFF
    {1, :T, :DW, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x1B do
    addr = w0 &&& 0xFF
    {1, :T, :FD, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x13 do
    addr = w0 &&& 0xFF
    {1, :T, :FW, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x0B do
    addr = w0 &&& 0xFF
    {1, :T, :FY, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x4B do
    addr = w0 &&& 0xFF
    {1, :T, :IB, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x5B do
    addr = w0 &&& 0xFF
    {1, :T, :ID, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x53 do
    addr = w0 &&& 0xFF
    {1, :T, :IW, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x77 do
    addr = w0 &&& 0xFF
    {1, :T, :OW, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x7F do
    addr = w0 &&& 0xFF
    {1, :T, :OY, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x7B do
    addr = w0 &&& 0xFF
    {1, :T, :PW, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x73 do
    addr = w0 &&& 0xFF
    {1, :T, :PY, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x4B do
    addr = (w0 &&& 0xFF) - 0x80
    {1, :T, :QB, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x5B do
    addr = (w0 &&& 0xFF) - 0x80
    {1, :T, :QD, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x53 do
    addr = (w0 &&& 0xFF) - 0x80
    {1, :T, :QW, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x6B do
    addr = w0 &&& 0xFF
    {1, :T, :RI, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x67 do
    addr = w0 &&& 0xFF
    {1, :T, :RJ, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x63 do
    addr = w0 &&& 0xFF
    {1, :T, :RS, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x6F do
    addr = w0 &&& 0xFF
    {1, :T, :RT, [addr]}
  end

  def translate([0x78FB | [w1 | _]]) when w1 >>> 12 == 0x0 do
    addr = w1 &&& 0xFFF
    {2, :T, :SD, [addr]}
  end

  def translate([0x78DB | [w1 | _]]) when w1 >>> 12 == 0x0 do
    addr = w1 &&& 0xFFF
    {2, :T, :SW, [addr]}
  end

  def translate([0x78BB | [w1 | _]]) when w1 >>> 12 == 0x0 do
    addr = w1 &&& 0xFFF
    {2, :T, :SY, [addr]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x66 do
    addr = w0 &&& 0xFF
    {1, :T_assign, :formal_operand, [addr]}
  end

  def translate([0x7015 | [w1 | _]]) when w1 >>> 12 == 0xC do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TB, :C, [bit, addr]}
  end

  def translate([0x7046 | [w1 | _]]) when w1 >>> 12 == 0xC do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TB, :D, [bit, addr]}
  end

  def translate([0x7049 | [w1 | _]]) when w1 >>> 12 == 0xC do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TB, :F, [bit, addr]}
  end

  def translate([0x7038 | [w1 | _]]) when w1 >>> 12 == 0xC do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF

    cond do
      addr < 0x80 -> {2, :TB, :I, [bit, addr]}
      addr >= 0x80 -> {2, :TB, :Q, [bit, addr - 0x80]}
    end
  end

  def translate([0x7047 | [w1 | _]]) when w1 >>> 12 == 0xC do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TB, :RI, [bit, addr]}
  end

  def translate([0x701E | [w1 | _]]) when w1 >>> 12 == 0xC do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TB, :RJ, [bit, addr]}
  end

  def translate([0x7057 | [w1 | _]]) when w1 >>> 12 == 0xC do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TB, :RS, [bit, addr]}
  end

  def translate([0x700E | [w1 | _]]) when w1 >>> 12 == 0xC do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TB, :RT, [bit, addr]}
  end

  def translate([0x7025 | [w1 | _]]) when w1 >>> 12 == 0xC do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TB, :T, [bit, addr]}
  end

  #
  def translate([0x7015 | [w1 | _]]) when w1 >>> 12 == 0x8 do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TBN, :C, [bit, addr]}
  end

  def translate([0x7046 | [w1 | _]]) when w1 >>> 12 == 0x8 do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TBN, :D, [bit, addr]}
  end

  def translate([0x7049 | [w1 | _]]) when w1 >>> 12 == 0x8 do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TBN, :F, [bit, addr]}
  end

  def translate([0x7038 | [w1 | _]]) when w1 >>> 12 == 0x8 do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF

    cond do
      addr < 0x80 -> {2, :TBN, :I, [bit, addr]}
      addr >= 0x80 -> {2, :TBN, :Q, [bit, addr - 0x80]}
    end
  end

  def translate([0x7047 | [w1 | _]]) when w1 >>> 12 == 0x8 do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TBN, :RI, [bit, addr]}
  end

  def translate([0x701E | [w1 | _]]) when w1 >>> 12 == 0x8 do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TBN, :RJ, [bit, addr]}
  end

  def translate([0x7057 | [w1 | _]]) when w1 >>> 12 == 0x8 do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TBN, :RS, [bit, addr]}
  end

  def translate([0x700E | [w1 | _]]) when w1 >>> 12 == 0x8 do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TBN, :RT, [bit, addr]}
  end

  def translate([0x7025 | [w1 | _]]) when w1 >>> 12 == 0x8 do
    addr = w1 &&& 0xFF
    bit = w1 >>> 8 &&& 0xF
    {2, :TBN, :T, [bit, addr]}
  end

  #
  def translate([0x7002 | _]) do
    {1, :TAK, :no_operand, []}
  end

  #
  def translate([0x680F | _]) do
    {1, :TDI, :A1, []}
  end

  def translate([0x682F | _]) do
    {1, :TDI, :A2, []}
  end

  def translate([0x689F | _]) do
    {1, :TDI, :BA, []}
  end

  def translate([0x68AF | _]) do
    {1, :TDI, :BR, []}
  end

  def translate([0x684F | _]) do
    {1, :TDI, :SA, []}
  end

  #
  def translate([w0 | _]) when w0 >>> 4 == 0x480 do
    value = w0 &&& 0xF
    {1, :TIR, :register_number, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x03 do
    value = w0 &&& 0xFF
    {1, :TNB, :constant, [value]}
  end

  def translate([w0 | _]) when w0 >>> 8 == 0x43 do
    value = w0 &&& 0xFF
    {1, :TNW, :constant, [value]}
  end

  #
  def translate([0x6805 | [w1 | _]]) do
    {2, :TRD, :constant, [w1]}
  end

  #
  def translate([0x6803 | [w1 | _]]) do
    {2, :TRW, :constant, [w1]}
  end

  #
  def translate([0x78CD | [w1 | _]]) do
    {2, :TSC, :constant, [w1]}
  end

  #
  def translate([0x78CE | [w1 | _]]) do
    {2, :TSG, :constant, [w1]}
  end

  #
  def translate([0x78ED | [w1 | _]]) do
    {2, :TW_CD, :constant, [w1]}
  end

  #
  def translate([0x78DD | [w1 | _]]) do
    {2, :TW_CW, :constant, [w1]}
  end

  #
  def translate([0x78EE | [w1 | _]]) do
    {2, :TW_GD, :constant, [w1]}
  end

  #
  def translate([0x78DE | [w1 | _]]) do
    {2, :TW_GW, :constant, [w1]}
  end

  #
  def translate([0x701F | _]) do
    {1, :TXB, :no_operand, []}
  end

  #
  def translate([0x700F | _]) do
    {1, :TXW, :no_operand, []}
  end

  #
  def translate([0x788D | [w1 | _]]) do
    {2, :TY_CB, :constant, [w1]}
  end

  #
  def translate([0x78AD | [w1 | _]]) do
    {2, :TY_CD, :constant, [w1]}
  end

  #
  def translate([0x789D | [w1 | _]]) do
    {2, :TY_CW, :constant, [w1]}
  end

  #
  def translate([0x788E | [w1 | _]]) do
    {2, :TY_GB, :constant, [w1]}
  end

  #
  def translate([0x78AE | [w1 | _]]) do
    {2, :TY_GD, :constant, [w1]}
  end

  #
  def translate([0x789E | [w1 | _]]) do
    {2, :TY_GW, :constant, [w1]}
  end

  #
  def translate([0x5100 | _]) do
    {1, :XOW, :no_operand, []}
  end

  #
  def translate([0xBF00 | _]) do
    {1, :rpar, :no_operand, []}
  end

  #
  def translate([0x783F | [w1 | _]]) when w1 >>> 12 == 0x6 do
    bit = w1 >>> 8 &&& 0xF
    addr = w1 &&& 0xFF
    {2, :assign, :D, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 12 == 0x9 and (w0 >>> 8 &&& 0xF) >= 0x8 do
    bit = (w0 >>> 8 &&& 0xF) - 0x8
    addr = w0 &&& 0xFF
    {1, :assign, :F, [bit, addr]}
  end

  def translate([w0 | _]) when w0 >>> 12 == 0xD and (w0 >>> 8 &&& 0xF) >= 0x8 do
    bit = (w0 >>> 8 &&& 0xF) - 0x8
    addr = w0 &&& 0xFF

    cond do
      addr < 0x80 -> {1, :assign, :I, [bit, addr]}
      addr >= 0x80 -> {1, :assign, :Q, [bit, addr - 0x80]}
    end
  end

  def translate([0x783B | [w1 | _]]) do
    bit = w1 >>> 12
    addr = w1 &&& 0xFFF
    {2, :assign, :S, [bit, addr]}
  end

  #
  def translate([w0 | _]) when w0 >>> 8 == 0x1F do
    value = w0 &&& 0xFF
    {1, :equal, :formal_operand, [value]}
  end

  #
  def translate([0x3920 | _]) do
    {1, :gt_D, :no_operand, []}
  end

  def translate([0x3940 | _]) do
    {1, :lt_D, :no_operand, []}
  end

  def translate([0x3960 | _]) do
    {1, :eq_D, :no_operand, []}
  end

  def translate([0x3980 | _]) do
    {1, :neq_D, :no_operand, []}
  end

  def translate([0x39A0 | _]) do
    {1, :gte_D, :no_operand, []}
  end

  def translate([0x39C0 | _]) do
    {1, :lte_D, :no_operand, []}
  end

  def translate([0x600D | _]) do
    {1, :add_D, :no_operand, []}
  end

  def translate([0x6009 | _]) do
    {1, :sub_D, :no_operand, []}
  end

  def translate([0x6000 | _]) do
    {1, :div_F, :no_operand, []}
  end

  def translate([0x6004 | _]) do
    {1, :mult_F, :no_operand, []}
  end

  def translate([0x7900 | _]) do
    {1, :add_F, :no_operand, []}
  end

  def translate([0x5900 | _]) do
    {1, :sub_F, :no_operand, []}
  end

  def translate([0x2180 | _]) do
    {1, :neq_F, :no_operand, []}
  end

  def translate([0x2120 | _]) do
    {1, :gt_F, :no_operand, []}
  end

  def translate([0x2140 | _]) do
    {1, :lt_F, :no_operand, []}
  end

  def translate([0x2160 | _]) do
    {1, :eq_F, :no_operand, []}
  end

  def translate([0x21A0 | _]) do
    {1, :gte_F, :no_operand, []}
  end

  def translate([0x21C0 | _]) do
    {1, :lte_F, :no_operand, []}
  end

  def translate([0x3120 | _]) do
    {1, :gt_G, :no_operand, []}
  end

  def translate([0x3140 | _]) do
    {1, :lt_G, :no_operand, []}
  end

  def translate([0x3160 | _]) do
    {1, :eq_G, :no_operand, []}
  end

  def translate([0x3180 | _]) do
    {1, :neq_G, :no_operand, []}
  end

  def translate([0x31A0 | _]) do
    {1, :gte_G, :no_operand, []}
  end

  def translate([0x31C0 | _]) do
    {1, :lte_G, :no_operand, []}
  end

  def translate([0x6003 | _]) do
    {1, :div_G, :no_operand, []}
  end

  def translate([0x6007 | _]) do
    {1, :mult_G, :no_operand, []}
  end

  def translate([0x600F | _]) do
    {1, :add_G, :no_operand, []}
  end

  def translate([0x600B | _]) do
    {1, :sub_G, :no_operand, []}
  end
end
