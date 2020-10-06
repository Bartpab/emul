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
    def translate({:LC, operand, [w0]}) do
        w0 = w0 &&& 0xFF
        case operand do
            :C -> [0x4C00 + w0]
            :T -> [0x0C00 + w0]
        end
    end
    def translate({:LDI, operand, _}) do
        case operand do
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
    def translate({:LW_assign, _, [w0]}) do 
        [0x3F00 + (w0 &&& 0xFF)]
    end
    def translate({:LW_CD, _, [w0]}) do
        [0x786D, w0 &&& 0xFFFF]
    end
    def translate({:LW_CW, _, [w0]}) do
        [0x785D, w0 &&& 0xFFFF]
    end
    def translate({:LW_GD, _, [w0]}) do
        [0x786E, w0 &&& 0xFFFF]
    end    
    def translate({:LW_GW, _, [w0]}) do
        [0x785E, w0 &&& 0xFFFF]
    end    
    def translate({:LY_CB, _, [w0]}) do
        [0x780D, w0 &&& 0xFFFF]
    end    
    def translate({:LY_CD, _, [w0]}) do
        [0x782D, w0 &&& 0xFFFF]
    end    
    def translate({:LY_CW, _, [w0]}) do
        [0x781D, w0 &&& 0xFFFF]
    end    
    def translate({:LY_GB, _, [w0]}) do
        [0x780E, w0 &&& 0xFFFF]
    end    
    def translate({:LY_GD, _, [w0]}) do
        [0x782E, w0 &&& 0xFFFF]
    end    
    def translate({:LY_GW, _, [w0]}) do
        [0x781E, w0 &&& 0xFFFF]
    end    
    def translate({:MAB, _, _}) do 
        [0x6829]
    end
    def translate({:MAS, _, _}) do
        [0x6819]
    end
    def translate({:MBA, _, _}) do
        [0x6889]
    end
    def translate({:MBR, _, [w0, w1]}) do
        [0x7809 + (w0 &&& 0xF <<< 4), w1 &&& 0xFFFF]
    end
    def translate({:MBS, _, _}) do
        [0x6899]
    end
    def translate({:MSA, _, _}) do
        [0x6849]
    end
    def translate({:MSB, _, _}) do
        [0x6869]
    end
    def translate({:NOP_0, _, _}) do
        [0x0000]
    end
    def translate({:NOP_1, _, _}) do 
        [0xFFFF]
    end
    def translate({:O, operand, args}) do
        case operand do
            :C -> 
                [w0] = args
                [0xB900 + (w0 &&& 0xFF)]
            :D ->
                [bit, addr] = args
                [0x783F, 0x1000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :F ->
                [bit, addr] = args
                [0x8800 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :I ->
                [bit, addr] = args
                [0xC000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]   
            :Q -> 
                [bit, addr] = args
                [0xC000 + ((bit &&& 0xF) <<< 8) + ((addr + 0x80) &&& 0xFF)]
            :S ->
                [bit, addr]  = args
                [0x781B, ((bit &&& 0xF) <<< 14) + (addr &&& 0xFFF)]
            :T ->
                [w0] = args
                [0xF900 + (w0 &&& 0xFF)]
            :no_operand ->
                [0xFB00]
        end
    end
    def translate({:O_lpar, _, _}) do
        [0xBB00]
    end
    def translate({:O_assign, _, [w0]}) do
        [0x0F00 + (w0 &&& 0xFF)]
    end
    def translate({:ON, operand, args}) do
        case operand do
            :C -> 
                [w0] = args
                [0xBD00 + (w0 &&& 0xFF)]
            :D ->
                [bit, addr] = args
                [0x783F, 0x3000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :F ->
                [bit, addr] = args
                [0xA800 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :I ->
                [bit, addr] = args
                [0xE000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]   
            :Q -> 
                [bit, addr] = args
                [0xE000 + ((bit &&& 0xF) <<< 8) + ((addr + 0x80) &&& 0xFF)]
            :S ->
                [bit, addr]  = args
                [0x785B, ((bit &&& 0xF) <<< 14) + (addr &&& 0xFFF)]
            :T ->
                [w0] = args
                [0xFD00 + (w0 &&& 0xFF)]
        end
    end
    def translate({:ON_assign, _, [w0]}) do
        [0x2F00 + (w0 &&& 0xFF)]
    end
    def translate({:OW, _, _}) do
        [0x4900]
    end
    def translate({:R, operand, args}) do
        case operand do
            :C -> 
                [w0] = args
                [0x7C00 + (w0 &&& 0xFF)]
            :D ->
                [bit, addr] = args
                [0x783F, 0x5000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :F ->
                [bit, addr] = args
                [0xB000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :I ->
                [bit, addr] = args
                [0xF000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]   
            :Q -> 
                [bit, addr] = args
                [0xF000 + ((bit &&& 0xF) <<< 8) + ((addr + 0x80) &&& 0xFF)]
            :S ->
                [bit, addr]  = args
                [0x786B, ((bit &&& 0xF) <<< 14) + (addr &&& 0xFFF)]
            :T ->
                [w0] = args
                [0x3C00 + (w0 &&& 0xFF)]
        end
    end
    def translate({:RA, _, _}) do
        [0x0880]
    end
    def translate({:RAE, _, _}) do
        [0x7810]
    end
    def translate({:RB_assign, _, [w0]}) do
        [0x3700 + (w0 &&& 0xFF)]
    end
    def translate({:RD_assign, _, [w0]}) do
        [0x3E00 + (w0 &&& 0xFF)]
    end
    def translate({:RLD, _, [w0]}) do
        [0x6400 + (w0 &&& 0xFF)]
    end
    def translate({:RRD, _, [w0]}) do
        [0x7400 + (w0 &&& 0xFF)]
    end    
    def translate({:RU, operand, [bit, addr]}) do
        case operand do
            :C -> [0x7015, ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :D -> [0x7046, ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :F -> [0x7049, ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :I -> [0x7038, ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :Q -> [0x7038, ((bit &&& 0xF) <<< 8) + ((addr+0x80) &&& 0xFF)]
            :RI -> [0x7047, ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RJ -> [0x701E, ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RS -> [0x7057, ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RT -> [0x700E, ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :T -> [0x7025, ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
        end
    end
    def translate({:S, operand, args}) do
        case operand do
            :C -> 
                [w0] = args
                [0x5C00 + (w0 &&& 0xFF)]
            :D ->
                [bit, addr] = args
                [0x783F, 0x4000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :F ->
                [bit, addr] = args
                [0x9000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :I ->
                [bit, addr] = args
                [0xD000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]   
            :Q -> 
                [bit, addr] = args
                [0xD000 + ((bit &&& 0xF) <<< 8) + ((addr + 0x80) &&& 0xFF)]
            :S ->
                [bit, addr]  = args
                [0x782B, ((bit &&& 0xF) <<< 14) + (addr &&& 0xFFF)]
        end
    end
    def translate({:S_assign, _, [w0]}) do
        [0x1700 + (w0 &&& 0xFF)]
    end
    def translate({:SD, _, [w0]}) do
        [0x2400 + (w0 &&& 0xFF)]
    end
    def translate({:SD_assign, _, [w0]}) do
        [0x2600 + (w0 &&& 0xFF)]
    end
    def translate({:SE, _, [w0]}) do
        [0x1C00 + (w0 &&& 0xFF)]
    end
    def translate({:SEC_assign, _, [w0]}) do
        [0x1E00 + (w0 &&& 0xFF)]
    end
    def translate({:SED, _, [w0]}) do
        [0x7806, (w0 &&& 0xFF)]
    end
    def translate({:SEE, _, [w0]}) do
        [0x7807, (w0 &&& 0xFF)]
    end
    def translate({:SF, _, [w0]}) do
        [0x1400 + (w0 &&& 0xFF)]
    end
    def translate({:SFD_assign, _, [w0]}) do
        [0x1600 + (w0 &&& 0xFF)]
    end
    def translate({:SIM, _, _}) do
        [0x700D]
    end
    def translate({:SLD, _, [w0]}) do
        [0x2900 + (w0 &&& 0xFF)]
    end
    def translate({:SLW, _, [w0]}) do
        [0x6100 + (w0 &&& 0xFF)]
    end
    def translate({:SP, _, [w0]}) do
        [0x3400 + (w0 &&& 0xFF)]
    end
    def translate({:SP_assign, _, [w0]}) do
        [0x3600 + (w0 &&& 0xFF)]
    end   
    def translate({:SRW, _, [w0]}) do
        [0x6900 + (w0 &&& 0xFF)]
    end 
    def translate({:SS, _, [w0]}) do
        [0x2C00 + (w0 &&& 0xFF)]
    end
    def translate({:SSD, _, [w0]}) do
        [0x7100 + (w0 &&& 0xFF)]
    end
    def translate({:SSU_assign, _, [w0]}) do
        [0x2E00 + (w0 &&& 0xFF)]
    end
    def translate({:SSW, _, [w0]}) do
        [0x6801 + (w0 &&& 0xF <<< 4)]
    end
    def translate({:STP, _, _}) do
        [0x7003]
    end
    def translate({:STS, _, _}) do
        [0x7000]
    end
    def translate({:STW, _, _}) do
        [0x7004]
    end
    def translate({:SU, operand, [bit, addr]}) do
        case operand do
            :C -> [0x7015, 0x4000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :D -> [0x7046, 0x4000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :F -> [0x7049, 0x4000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :I -> [0x7038, 0x4000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :Q -> [0x7038, 0x4000 + ((bit &&& 0xF) <<< 8) + ((addr+0x80) &&& 0xFF)]
            :RI -> [0x7047, 0x4000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RJ -> [0x701E, 0x4000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RS -> [0x7057, 0x4000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RT -> [0x700E, 0x4000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :T -> [0x7025, 0x4000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
        end
    end
    def translate({:T, operand, [w0]}) do
        case operand do
            :DD -> [0x3B00 + (w0 &&& 0xFF)]
            :DL -> [0x2300 + (w0 &&& 0xFF)]
            :DR -> [0x2B00 + (w0 &&& 0xFF)]
            :DW -> [0x3300 + (w0 &&& 0xFF)]
            :FD -> [0x1B00 + (w0 &&& 0xFF)]
            :FW -> [0x1300 + (w0 &&& 0xFF)]
            :FY -> [0x0B00 + (w0 &&& 0xFF)]
            :IB -> [0x4B00 + (w0 &&& 0xFF)]
            :ID -> [0x5B00 + (w0 &&& 0xFF)]
            :IW -> [0x5300 + (w0 &&& 0xFF)]
            :OW -> [0x7700 + (w0 &&& 0xFF)]
            :OY -> [0x7F00 + (w0 &&& 0xFF)]
            :PW -> [0x7B00 + (w0 &&& 0xFF)]
            :PY -> [0x7300 + (w0 &&& 0xFF)]
            :QB -> [0x4B00 + ((w0+0x80) &&& 0xFF)]
            :QD -> [0x5B00 + ((w0+0x80) &&& 0xFF)]
            :QW -> [0x5300 + ((w0+0x80) &&& 0xFF)]
            :RI -> [0x6B00 + (w0 &&& 0xFF)]
            :RJ -> [0x6700 + (w0 &&& 0xFF)]
            :RS -> [0x6300 + (w0 &&& 0xFF)]
            :RT -> [0x6F00 + (w0 &&& 0xFF)]
            :SD -> [0x78FB, (w0 &&& 0xFFF)]
            :SW -> [0x78DB, (w0 &&& 0xFFF)]
            :SY -> [0x78BB, (w0 &&& 0xFFF)]
        end
    end
    def translate({:T_assign, _, [w0]}) do
        [0x6600 + (w0 &&& 0xFF)]
    end
    def translate({:TB, operand, [bit, addr]}) do
        case operand do
            :F -> [0x7049, 0xC000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :I -> [0x7038, 0xC000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :Q -> [0x7038, 0xC000 + ((bit &&& 0xF) <<< 8) + ((addr+0x80) &&& 0xFF)]
            :RI -> [0x7047, 0xC000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RJ -> [0x701E, 0xC000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RS -> [0x7057, 0xC000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RT -> [0x700E, 0xC000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :T -> [0x7025, 0xC000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
        end
    end    
    def translate({:TBN, operand, [bit, addr]}) do
        case operand do
            :C -> [0x7015, 0x8000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :D -> [0x7046, 0x8000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :F -> [0x7049, 0x8000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :I -> [0x7038, 0x8000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :Q -> [0x7038, 0x8000 + ((bit &&& 0xF) <<< 8) + ((addr+0x80) &&& 0xFF)]
            :RI -> [0x7047, 0x8000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RJ -> [0x701E, 0x8000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RS -> [0x7057, 0x8000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :RT -> [0x700E, 0x8000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :T -> [0x7025, 0x8000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
        end
    end
    def translate({:TAK, _, _}) do
        [0x7002]
    end
    def translate({:TDI, operand, _}) do
        case operand do
            :A1 -> [0x680F]
            :A2 -> [0x682F]
            :BA -> [0x689F]
            :BR -> [0x68AF]
            :SA -> [0x684F]
        end
    end
    def translate({:TIR, _, [w0]}) do
        [0x4800 + (w0 &&& 0xF)]
    end
    def translate({:TNB, _, [w0]}) do
        [0x0300 + (w0 &&& 0xFF)]
    end
    def translate({:TNW, _, [w0]}) do
        [0x4300 + (w0 &&& 0xFF)]
    end
    def translate({:TRD, _, [w0]}) do
        [0x6805, w0 &&& 0xFFFF]
    end
    def translate({:TRW, _, [w0]}) do
        [0x6803, w0 &&& 0xFFFF]
    end
    def translate({:TSC, _, [w0]}) do
        [0x78CD, w0 &&& 0xFFFF]
    end
    def translate({:TSG, _, [w0]}) do
        [0x78CE, w0 &&& 0xFFFF]
    end
    def translate({:TW_CD, _, [w0]}) do
        [0x78ED, w0 &&& 0xFFFF]
    end
    def translate({:TW_CW, _, [w0]}) do
        [0x78DD, w0 &&& 0xFFFF]
    end
    def translate({:TW_GD, _, [w0]}) do
        [0x78EE, w0 &&& 0xFFFF]
    end
    def translate({:TW_GW, _, [w0]}) do
        [0x78DE, w0 &&& 0xFFFF]
    end
    def translate({:TXB, _, _}) do
        [0x701F]
    end
    def translate({:TXW, _, _}) do
        [0x700F]
    end
    def translate({:TY_CB, _, [w0]}) do
        [0x788D, w0 &&& 0xFFFF]
    end
    def translate({:TY_CD, _, [w0]}) do
        [0x78AD, w0 &&& 0xFFFF]
    end
    def translate({:TY_CW, _, [w0]}) do
        [0x789D, w0 &&& 0xFFFF]
    end
    def translate({:TY_GB, _, [w0]}) do
        [0x788E, w0 &&& 0xFFFF]
    end
    def translate({:TY_GD, _, [w0]}) do
        [0x78AE, w0 &&& 0xFFFF]
    end
    def translate({:TY_GW, _, [w0]}) do
        [0x789E, w0 &&& 0xFFFF]
    end
    def translate({:XOW, _, _}) do
        [0x5100]
    end
    def translate({:rpar, _, _}) do
        [0xBF00]
    end
    def translate({:assign, operand, [bit, addr]}) do
        case operand do
            :D -> [0x783F, 0x6000 + ((bit &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :F -> [0x9000 + (((bit + 0x8) &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :I -> [0x9000 + (((bit + 0x8) &&& 0xF) <<< 8) + (addr &&& 0xFF)]
            :Q -> [0x9000 + (((bit + 0x8) &&& 0xF) <<< 8) + ((addr + 0x80) &&& 0xFF)]
            :S -> [0x783B, (((bit + 0x8) &&& 0xF) <<< 12) + (addr &&& 0xFF)]
        end
    end
    def translate({:equal, _, [w0]}) do
        [0x1F00 + (w0 &&& 0xFF)]
    end

end