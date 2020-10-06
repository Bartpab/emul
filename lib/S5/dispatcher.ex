defmodule Emulators.S5.Dispatcher do   
    use Bitwise 
    import Emulators.S5.Guards

    # A
    def dispatch(%{:sm => sm} = state, {:A, operand, args}) 
    when operand in [:I, :Q, :F, :S, :D, :T, :C]
    do
        result = sm.get(state, :RLO) &&& sm.get(state, operand, args)
        state |> sm.set(:RLO, result) 
    end

    # AN
    def dispatch(%{:sm => sm} = state, {:AN, operand, args})
    when operand in [:I, :Q, :F, :S, :D, :T, :C]
    do
        result = sm.get(state, :RLO) &&& ~~~sm.get(state, operand, args)
        state |> sm.set(:RLO, result) 
    end

    # O
    def dispatch(%{:sm => sm} = state, {:O, operand, args})
    when operand in [:I, :Q, :F, :S, :D, :T, :C]
    do
        result = sm.get(state, :RLO) ||| sm.get(state, operand, args)
        state |> sm.set(:RLO, result)         
    end

    # ON
    def dispatch(%{:sm => sm} = state, {:ON, operand, args})
    when operand in [:I, :Q, :F, :S, :D, :T, :C]
    do
        result = sm.get(state, :RLO) ||| ~~~sm.get(state, operand, args)
        state |> sm.set(:RLO, result)         
    end

    # S
    def dispatch(%{:sm => sm} = state, {:S, operand, args})
    when operand in [:I, :Q, :F, :S, :D]
    do
        rlo = sm.get(state, :RLO)
        if rlo == 1 do
            sm.set(state, operand, args, 1)
        else
            state
        end
    end
    
    # R
    def dispatch(%{:sm => sm} = state, {:R, operand, args})
    when operand in [:I, :Q, :F, :S, :D]
    do
        rlo = state |> sm.get(:RLO)
        
        if rlo == 1 do
            sm.set(state, operand, args, 0)
        else
            state
        end

    end

    # = 
    def dispatch(%{:sm => sm} = state, {:assign, operand, args})
    when operand in [:I, :Q, :F, :S, :D]
    do
        sm.set(state, operand, args, sm.get(:RLO))
    end
    
    # L
    # L IB/QB/FY/SY
    def dispatch(%{:sm => sm} = state, {:L, operand, args})
    when operand in [:IB, :QB, :FY, :SY, :PY, :OY]
    do
        byte = sm.get(state, operand, args)
        state 
        |> sm.set(:ACCU_1_L, byte)
    end
    # L T/C
    def dispatch(%{:sm => sm} = state, {:L, operand, args})
    when operand in [:C, :T]
    do   
        word = sm.get(state, operand, args)
        state 
        |> sm.set(:ACCU_1_L, word)
    end 
    # L IW/QW/FW/SW/PW/OW
    def dispatch(%{:sm => sm} = state, {:L, operand, args})
    when operand in [:IW, :QW, :FW, :SW, :PW, :OW]
    do
        word = sm.get(state, operand, args)
        
        b0 = (word &&& 0xFF) <<< 8
        b1 = (word &&& 0xFF) >>> 8

        state 
        |> sm.set(:ACCU_1_L, b0 + b1)
    end
end