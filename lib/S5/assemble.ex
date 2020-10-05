defmodule Emulators.S5.Assemble do
    use Bitwise

    def translate({:A, operand, args}) do
        case operand do
            :C -> 
                [addr] = args
                [0xB800 + (addr &&& 0xFF)]
            
            :D ->
                [bit, addr] = args
                [0x783F, (bit &&& 0xF) <<< 8 + (addr &&& 0xFF)]
            :F ->
                [bit, addr] = args
                [0x8000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :I ->
                [bit, addr] = args
                [0xC000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :Q ->
                [bit, addr] = args
                [0xC000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF + 0x80)] 
            :S -> 
                [bit, addr] = args
                [0x780B, ((bit &&& 0xF) <<< 12) + (addr &&& 0xFFF)]
            :T ->
                [addr] = args
                [0xF800 + (addr && 0xFF)]
        end
    end
    def translate({:A_lpar, _, _}) do
        [0xBA00]
    end
    def translate({:A_assign, _, [w0]}) do
        [0x0700 + (w0 &&& 0xFF)]
    end
    def translate({:ABR, _, [w0]}) do
        [0x780A, w0 &&& 0xFFFF]
    end
    def translate({:ACR, _, _}) do
        [0x783D]
    end
    def translate({:ADD, :BN, [w0]}) do
        [0x5000 + (w0 &&& 0xFF)]
    end
    def translate({:ADD, :DH, [w0, w1]}) do
        [0x6005, (w0 &&& 0xFFFF), (w1 &&& 0xFFFF)]
    end
    def translate({:ADD, :KF, [w0]}) do
        [0x5800, w0 &&& 0xFFFF]
    end
    def translate({:AN, :C, [w0]}) do
        [0xBC00 + (w0 &&& 0xFF)]
    end
    def translate({:AN, :D, [b0, w1]}) do
        [0x783F, 0x4000 + ((b0 &&& 0xF) <<< 8) + (w1 &&& 0xFF)]
    end
    def translate({:AN, :F, [b0, w1]}) do
        [0xA000 + ((b0 &&& 0xF) <<< 8) + (w1 &&& 0xFF)]
    end
    def translate({:AN, operand, [b0, w1]}) when operand == :I or operand ==:Q do
        case operand do
            :I -> [
                0xE000 + ((b0 &&& 0xF) <<< 8) + (w1 &&& 0xFF)
            ]
            :Q -> [
                0xE000 + ((b0 &&& 0xF) <<< 8) + (w1 &&& 0xFF) + 0x80 
            ]
        end
    end
    def translate({:AN, :S, [b0, w1]}) do
        [0x784B, (b0 <<< 12) + (w1 &&& 0xFF)]
    end
    def translate({:AN, :T, [w0]}) do
        [0xFC00 + (w0 &&& 0xFF)]
    end
    def translate({:AN_assign, _, [w0]}) do
        [0x2700 + (w0 &&& 0xFF)]
    end
    def translate({:AW, _, _}) do
        [0x4100]
    end
    def translate({:BAF, _, _}) do
        [0xFE00]
    end
    def translate({:BAS, _, _}) do
        [0xBE00]
    end
    def translate({:BE, _, _}) do
        [0x6500]
    end
    def translate({:BEC, _, _}) do
        [0x0500]
    end
    def translate({:BEU, _, _}) do
        [0x6501]
    end
    def translate({:BLD, _, [w0]}) do
        [0x1000 + (w0 &&& 0xFF)]
    end
    def translate({:C, :DB, [w0]}) do
        [0x2000 + (w0 &&& 0xFF)]
    end
    def translate({:CD, :C, [w0]}) do
        [0x5400 + (w0 &&& 0xFF)]
    end
    def translate({:CFW, _, _}) do
        [0x0100]
    end
    def translate({:CSD, _, _}) do
        [0x6807]
    end
    def translate({:CSW, _, _}) do
        [0x0900]
    end
    def translate({:CU, :C, [w0]}) do
        [0x6C00 + (w0 &&& 0xFF)]
    end
    def translate({:CX, :DX, [w0]}) do
        [0x7803, 0x1100 + (w0 &&& 0xFF)]
        end
    def translate({:D, _, [w0]}) do
        [0x1900 + (w0 &&& 0xFF)]
    end
    def translate({:DED, _, _}) do
        [0x680E]
    end
    def translate({:DEF, 0x680C}) do 
        [0x680C]
    end
    def translate({:DI, _, _}) do
        [0x7E00]
    end
    def translate({:DO, operand, [w0]}) do
        w0 = w0 &&& 0xFF
        case operand do
            :DW -> [0x6E00 + w0]
            :FW -> [0x4E00 + w0]
            :RS -> [0x1800 + w0]
        end
    end
    def translate({:DO_assign, _, [w0]}) do
        [0x7600 + (w0 &&& 0xFF)]
    end
    def translate({:DOC, :FX, [w0]}) do
        [0x7802, 0x0900 + (w0 &&& 0xFF)]
    end
    def translate({:DOU, :FX, [w0]}) do
        [0x7801, 0x0100 + (w0 &&& 0xFF)]
    end
    def translate({:DUD, _, _}) do
        [0x680A]
    end
    def translate({:DUF, _, _}) do
        [0x6808]
    end
    def translate({:ENT, _, _}) do
        [0x6008]
    end
    def translate({:FDG, _, _}) do
        [0x6806]
    end
    def translate({:FR, operand, [w0]}) do
        w0 = 0xFF &&& w0
        case operand do
            :C -> [0x4400 + w0]
            :T -> [0x0400 + w0]
        end
    end
    def translate({:FR_assign, _, [w0]}) do
        w0 = 0xFF &&& w0
        [0x0600 + w0]
    end
    def translate({:G, :DB, [w0]}) do
        [0x7805, w0 &&& 0xFF]
    end
    def translate({:GFD, _, _}) do
        [0x6802]
    end
    def translate([:GX, :DX, [w0]]) do
        [0x7804, w0 &&& 0xFF]
    end
    def translate({:I, _, [w0]}) do 
        [0x1100 + (w0 &&& 0xFF)]
    end
    def translate({:IA, _, _}) do
        [0x7800]
    end
    def translate({:JC, operand, [w0]}) do 
        w0 = w0 &&& 0xFF
        case operand do 
            :FB -> [0x1D00 + w0]
            :OB -> [0x4D00 + w0]
            :PB -> [0x5500 + w0]
            :SB -> [0x5D00 + w0]
        end
    end
    def translate({:JC_assign, _, [w0]}) do
        [0xFA00 + (w0 &&& 0xFF)]
    end
    def translate({:JM_assign, _, [w0]}) do
        [0x2500 + (w0 &&& 0xFF)]
    end
    def translate({:JN_assign, _, [w0]}) do 
        [0x3500 + (w0 &&& 0xFF)]
    end
    def translate({:JO_assign, _, [w0]}) do
        [0x0D00 + (w0 &&& 0xFF)]
    end
    def translate({:JOS_assign, _, [w0]}) do 
        [0x600C, (w0 &&& 0xFF)]
    end
    def translate({:JP_assign, _, [w0]}) do
        [0x1500 + (w0 &&& 0xFF)]
    end
    def translate({:JU, operand, [w0]}) do
        w0 = w0 &&& 0xFF
        case operand do 
            :FB -> [0x3D00 + w0]
            :OB -> [0x6D00 + w0]
            :PB -> [0x7500 + w0]
            :SB -> [0x7D00 + w0]
        end
    end
    def translate({:JU_assign, _, [w0]}) do
        [0x2D00 + (w0 &&& 0xFF)]
    end
    def translate({:JUR, _, [w0]}) do 
        [0x700B, w0]
    end
    def translate({:JZ_assign, _, [w0]}) do
        [0x4500 + (w0 &&& 0xFF)]
    end
    def translate({:L, operand, [w0]}) do
        case operand do
            :C -> [0x4200 + (w0 &&& 0xFF)]
            :DD -> [0x3A00 + (w0 &&& 0xFF)]
            :DL -> [0x2200 + (w0 &&& 0xFF)]
            :DR -> [0x2A00 + (w0 &&& 0xFF)]
            :DW -> [0x3200 + (w0 &&& 0xFF)]
            :FD -> [0x1A00 + (w0 &&& 0xFF)]
            :FW -> [0x1200 + (w0 &&& 0xFF)]
            :FY -> [0x0A00 + (w0 &&& 0xFF)]
            :IB -> [0x4A00 + (w0 &&& 0xFF)]
            :ID -> [0x5A00 + (w0 &&& 0xFF)]
            :IW -> [0x5200 + (w0 &&& 0xFF)]
            :KB -> [0x2800 + (w0 &&& 0xFF)]
            :KC -> [0x3001, w0 &&& 0xFFFF]
            :KF -> [0x3004, w0 &&& 0xFFFF]
            :KH -> [0x3040, w0 &&& 0xFFFF]
            :KM -> [0x3080, w0 &&& 0xFFFF]
            :KS -> [0x3010, w0 &&& 0xFFFF]
            :KT -> [0x3002, w0 &&& 0xFFFF]
            :KY -> [0x3020, w0 &&& 0xFFFF]
            :OW -> [0x5700 + (w0 &&& 0xFF)]
            :OY -> [0x5F00 + (w0 &&& 0xFF)]
            :PW -> [0x7A00 + (w0 &&& 0xFF)]
            :PY -> [0x7200 + (w0 &&& 0xFF)]
            :QB -> [0x4A00 + ((w0 &&& 0xFF) + 0x80)]
            :QD -> [0x5A00 + ((w0 &&& 0xFF) + 0x80)]
            :QW -> [0x5200 + ((w0 &&& 0xFF) + 0x80)]
            :RI -> [0x6A00 + (w0 &&& 0xFF)]
            :RJ -> [0x4700 + (w0 &&& 0xFF)]
            :RS -> [0x6200 + (w0 &&& 0xFF)]
            :RT -> [0x4F00 + (w0 &&& 0xFF)]
            :SD -> [0x78EB, w0 &&& 0xFFF]
            :SW -> [0x78CB, w0 &&& 0xFFF]
            :SY -> [0x78AB, w0 &&& 0xFFF]
            :T -> [0x0200 + (w0 &&& 0xFF)]
        end
    end
    def translate({:L, operand, [w0, w1]}) do
        case operand do
            :DH -> [0x3840, w0 &&& 0xFFFF, w1 &&& 0xFFFF]
            :KG -> [0x3800, w0 &&& 0xFFFF, w1 &&& 0xFFFF]
        end
    end
    def translate({:L_assign, _, [w0]}) do
        [0x4600 + (w0 &&& 0xFF)]
    end
    def translate({:L, operand, [w0]}) do
        w0 = w0 &&& 0xFF
        case operand do
            :C -> [0x4C00 + w0]
            :T -> [0x0C00 + w0]
        end
    end
    def translate({:LDI, operand, _}) do
        case operand ->
            :A1 -> [0x680B]
            :A2 -> [0x682B]
            :BA -> [0x689B]
            :BR -> [0x68AB]
            :SA -> [0x684B]
        end
    end
    def translate({:LD_assign, _, [w0]}) do
        [0x0E00 + (w0 &&& 0xFF)]
    end
    def translate({:LDW_assign, _, [w0]}) do
        [0x5600 + (w0 &&& 0xFF)]
    end
    def translate({:LIM, _, _}) do
        [0x700C]
    end
    def translate({:LIR, _, [w0]}) do
        [0x4000 + (w0 &&& 0xF)]
    end
    def translate({:LRD, _, [w0]}) do 
        [0x6804, w0 &&& 0xFFFF]
    end
    def translate({:LRW, _, [w0]}) do
        [0x6800, w0 &&& 0xFFFF]
    end
end