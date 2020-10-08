defmodule Emulators.S5.Dispatcher do
    use Bitwise
    alias Emulators.S5.AP.State

    # A
    def dispatch(state, {:A, operand, args})
    when operand in [:I, :Q, :F, :S, :D, :T, :C]
    do
        result = State.get(state, :RLO) &&& State.get(state, operand, args)
        state |> State.set(:RLO, result)
    end

    # AN
    def dispatch(state, {:AN, operand, args})
    when operand in [:I, :Q, :F, :S, :D, :T, :C]
    do
        result = State.get(state, :RLO) &&& ~~~State.get(state, operand, args)
        state |> State.set(:RLO, result)
    end

    # O
    def dispatch(state, {:O, operand, args})
    when operand in [:I, :Q, :F, :S, :D, :T, :C]
    do
        result = State.get(state, :RLO) ||| State.get(state, operand, args)
        state |> State.set(:RLO, result)
    end

    # ON
    def dispatch(state, {:ON, operand, args})
    when operand in [:I, :Q, :F, :S, :D, :T, :C]
    do
        result = State.get(state, :RLO) ||| ~~~State.get(state, operand, args)
        state |> State.set(:RLO, result)
    end

    # S
    def dispatch(state, {:S, operand, args})
    when operand in [:I, :Q, :F, :S, :D]
    do
        rlo = State.get(state, :RLO)
        if rlo == 1 do
            State.set(state, operand, args, 1)
        else
            state
        end
    end

    # R
    def dispatch(state, {:R, operand, args})
    when operand in [:I, :Q, :F, :S, :D]
    do
        rlo = state |> State.get(:RLO)

        if rlo == 1 do
            State.set(state, operand, args, 0)
        else
            state
        end

    end

    # =
    def dispatch(state, {:assign, operand, args})
    when operand in [:I, :Q, :F, :S, :D]
    do
        State.set(state, operand, args, state |> State.get(:RLO))
    end

    # L
    # L IB/QB/FY/SY
    def dispatch(state, {:L, operand, args})
    when operand in [:IB, :QB, :FY, :SY, :PY, :OY]
    do
        byte = State.get(state, operand, args)
        state
        |> State.set(:ACCU_1_L, byte)
    end
    # L T/C
    def dispatch(state, {:L, operand, args})
    when operand in [:C, :T]
    do
        word = State.get(state, operand, args)
        state |> State.set(:ACCU_1_L, word)
    end
    # L IW/QW/FW/SW/PW/OW
    def dispatch(state, {:L, operand, args})
    when operand in [:IW, :QW, :FW, :SW, :PW, :OW]
    do
        word = State.get(state, operand, args)

        b0 = (word &&& 0xFF) <<< 8
        b1 = (word &&& 0xFF) >>> 8

        state |> State.set(:ACCU_1_L, b0 + b1)
    end
end
