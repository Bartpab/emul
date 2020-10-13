defmodule EmulatorsTest.S5.Disassembler do
  use ExUnit.Case
  use Bitwise
  alias Emulators.S5.Disassembler
  doctest Emulators

  test "A C 0xAB" do
    assert {2, :A, :C, [0xAB]} = Disassembler.translate([0xB8AB])
  end

  test "A D 0x0CBA" do
    assert {2, :A, :D, [0x0C, 0xBA]} = Disassembler.translate([0x783F, 0x0CBA])
  end

  test "A F 0xCBA" do
    assert {1, :A, :F, [0xC, 0xBA]} = Disassembler.translate([0x8CBA])
  end

  test "A Q 0xCBA" do
    v = 0xBA - 0x80
    assert {1, :A, :Q, [0xC, ^v]} = Disassembler.translate([0xCCBA])
  end

  test "A S 0xDCBA" do
    assert {2, :A, :S, [0xD, 0xCBA]} = Disassembler.translate([0x780B, 0xDCBA])
  end

  test "A T 0xBA" do
    assert {1, :A, :T, [0xBA]} = Disassembler.translate([0xF8BA])
  end

  test "A(" do
    assert {1, :A_lpar, :no_operand, []} = Disassembler.translate([0xBA00])
  end

  test "A=" do
    assert {1, :A_assign, :formal_operand, [0xBA]} = Disassembler.translate([0x07BA])
  end

  test "ABR" do
    assert {2, :ABR, :constant, [0xDCBA]} = Disassembler.translate([0x780A, 0xDCBA])
  end

  test "ACR" do
    assert {1, :ACR, :no_operand, []} = Disassembler.translate([0x783D])
  end

  test "ADD BN 0xBA" do
    assert {1, :ADD, :BN, [0xBA]} = Disassembler.translate([0x50BA])
  end

  test "ADD DH 0xDCBA 0xFEDC" do
    assert {3, :ADD, :DH, [0xDCBA, 0xFEDC]} = Disassembler.translate([0x6005, 0xDCBA, 0xFEDC])
  end

  test "ADD KF 0xDCBA" do
    assert {2, :ADD, :KF, [0xDCBA]} = Disassembler.translate([0x5800, 0xDCBA])
  end

  test "AN C 0xBA" do
    assert {1, :AN, :C, [0xBA]} = Disassembler.translate([0xBCBA])
  end

  test "AN D 0xACD" do
    assert {2, :AN, :D, [0xA, 0xCD]} = Disassembler.translate([0x783F, 0x4ACD])
  end

  test "AN F 0xBCD" do
    assert {1, :AN, :F, [0xB, 0xCD]} = Disassembler.translate([0xABCD])
  end

  test "AN Q 0xBCD" do
    assert {1, :AN, :Q, [0xB, 0xCD - 0x80]} == Disassembler.translate([0xEBCD])
  end

  test "AN S 0xBCDA" do
    assert {2, :AN, :S, [0xB, 0xCDA]} == Disassembler.translate([0x784B, 0xBCDA])
  end

  test "AN T 0xBA" do
    assert {1, :AN, :T, [0xBA]} == Disassembler.translate([0xFCBA])
  end

  test "AN= 0xBA" do
    assert {1, :AN_assign, :formal_operand, [0xBA]} == Disassembler.translate([0x27BA])
  end

  test "AW" do
    assert {1, :AW, :no_operand, []} == Disassembler.translate([0x4100])
  end

  test "BAF" do
    assert {1, :BAF, :no_operand, []} == Disassembler.translate([0xFE00])
  end

  test "BAS" do
    assert {1, :BAS, :no_operand, []} == Disassembler.translate([0xBE00])
  end

  test "BE" do
    assert {1, :BE, :no_operand, []} == Disassembler.translate([0x6500])
  end

  test "BEC" do
    assert {1, :BEC, :no_operand, []} == Disassembler.translate([0x0500])
  end

  test "BEU" do
    assert {1, :BEU, :no_operand, []} == Disassembler.translate([0x6501])
  end

  test "BLD" do
    assert {1, :BLD, :constant, [0xBA]} == Disassembler.translate([0x10BA])
  end

  test "C DB 0xDA" do
    assert {1, :C, :DB, [0xDA]} = Disassembler.translate([0x20DA])
  end

  test "CD C 0xDA" do
    assert {1, :CD, :C, [0xDA]} = Disassembler.translate([0x54DA])
  end

  test "CFW" do
    assert {1, :CFW, :no_operand, []} = Disassembler.translate([0x0100])
  end

  test "CSD" do
    assert {1, :CSD, :no_operand, []} = Disassembler.translate([0x6807])
  end

  test "CSW" do
    assert {1, :CSW, :no_operand, []} = Disassembler.translate([0x0900])
  end

  test "CU C 0xBA" do
    assert {1, :CU, :C, [0xBA]} = Disassembler.translate([0x6CBA])
  end

  test "CX DX 0xBA" do
    assert {2, :CX, :DX, [0xBA]} = Disassembler.translate([0x7803, 0x11BA])
  end

  test "D 0xBA" do
    assert {1, :D, :constant, [0xBA]} = Disassembler.translate([0x19BA])
  end

  test "DED" do
    assert {1, :DED, :no_operand, []} = Disassembler.translate([0x680E])
  end

  test "DEF" do
    assert {1, :DEF, :no_operand, []} = Disassembler.translate([0x680C])
  end

  test "DI" do
    assert {1, :DI, :no_operand, []} = Disassembler.translate([0x7E00])
  end

  test "DO DW 0xBA" do
    assert {1, :DO, :DW, [0xBA]} = Disassembler.translate([0x6EBA])
  end

  test "DO FW 0xBA" do
    assert {1, :DO, :FW, [0xBA]} = Disassembler.translate([0x4EBA])
  end

  test "DO RS 0xBA" do
    assert {1, :DO, :RS, [0xBA]} = Disassembler.translate([0x18BA])
  end

  test "DO= 0xBA" do
    assert {1, :DO_assign, :formal_operand, [0xBA]} = Disassembler.translate([0x76BA])
  end

  test "DOC FX 0xBA" do
    assert {2, :DOC, :FX, [0xBA]} =
             Disassembler.translate([
               0x7802,
               0x09BA
             ])
  end

  test "DOU FX 0xBA" do
    assert {2, :DOU, :FX, [0xBA]} =
             Disassembler.translate([
               0x7801,
               0x01BA
             ])
  end

  test "DUD" do
    assert {1, :DUD, :no_operand, []} =
             Disassembler.translate([
               0x680A
             ])
  end

  test "DUF" do
    assert {1, :DUF, :no_operand, []} =
             Disassembler.translate([
               0x6808
             ])
  end

  test "ENT" do
    assert {1, :ENT, :no_operand, []} =
             Disassembler.translate([
               0x06008
             ])
  end

  test "FDG" do
    assert {1, :FDG, :no_operand, []} =
             Disassembler.translate([
               0x6806
             ])
  end

  test "FR C 0xBA" do
    assert {1, :FR, :C, [0xBA]} =
             Disassembler.translate([
               0x44BA
             ])
  end

  test "FR T 0xBA" do
    assert {1, :FR, :T, [0xBA]} =
             Disassembler.translate([
               0x04BA
             ])
  end

  test "FR= 0xBA" do
    assert {1, :FR_assign, :formal_operand, [0xBA]} =
             Disassembler.translate([
               0x06BA
             ])
  end

  test "G DB 0xBA" do
    assert {2, :G, :DB, [0xBA]} =
             Disassembler.translate([
               0x7805,
               0x00BA
             ])
  end

  test "GFD" do
    assert {1, :GFD, :no_operand, []} =
             Disassembler.translate([
               0x6802
             ])
  end

  test "GX DX 0xBA" do
    assert {2, :GX, :DX, [0xBA]} =
             Disassembler.translate([
               0x7804,
               0x00BA
             ])
  end

  test "I 0xBA" do
    assert {1, :I, :constant, [0xBA]} =
             Disassembler.translate([
               0x11BA
             ])
  end

  test "IA" do
    assert {1, :IA, :no_operand, []} =
             Disassembler.translate([
               0x0800
             ])
  end

  test "IAE" do
    assert {1, :IAE, :no_operand, []} =
             Disassembler.translate([
               0x7800
             ])
  end
end
