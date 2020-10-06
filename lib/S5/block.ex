defmodule Emulators.S5.Block do
    use Bitwise

    @header_size 6
    @block_magic 0x7070

    def get_block_type(infos) do
        case infos &&& 0x3F do
            0x01 -> :DB
            0x02 -> :SB
            0x04 -> :PB
            0x05 -> :FX
            0x08 -> :FB
            0x0C -> :DX
            0x10 -> :OB
            _ -> raise "Uknown block type."
        end
    end

    def reverse_block_type(type) do
        case type do
            :DB -> 0x01
            :SB -> 0x02
            :PB -> 0x04
            :FX -> 0x05
            :FB -> 0x08
            :DX -> 0x0C
            :OB -> 0x10
            _ -> raise "Unknown block type"
        end
    end

    def get_block_validity(infos) do
        case infos &&& 0xC0 do
            0x00 -> :invalid
            0x01 -> :valid
            _ -> raise "Wrong validity infos."
        end
    end

    def read_block(memory) when is_list(memory) do
        [w0, w1, w2, w3, w4] = memory |> Enum.take(@header_size)

        unless w0 == @block_magic do
            raise "Not a block"
        end

        infos = (w1 >>> 8)
        id = (w1 &&& 0xFF)
        type = Emulators.S5.Block.get_block_type(infos)
        validity = Emulators.S5.Block.get_block_validity(infos)
        pids = (w2 >>> 8)
        lids = [w2 &&& 0xFF, w3]
        size = w4

        body = memory |> Enum.slice(@header_size, size - @header_size)

        %{headers: %{
            id: id,
            type: type,
            validity: validity,
            size: size,
            pids: pids,
            lids: lids
        }, body: body}
    end

    def write_block(id, type, pids, lids, body) do
        size = @header_size + (body |> Enum.count)
        infos = (0b00 <<< 6) + Emulators.S5.Block.reverse_block_type(type)
        [lid0, lid1] = lids

        w0 = 0x7070
        w1 = (infos <<< 8) + (id && 0xFF)
        w2 = (pids <<< 8) + (lid0 && 0xFF)
        w3 = lid1
        w4 = size

        header = [w0, w1, w2, w3, w4]
        Enum.concat(header, body)
    end

end
