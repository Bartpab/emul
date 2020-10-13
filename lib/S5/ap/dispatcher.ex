defmodule Emulators.S5.Dispatcher do
  use Bitwise

  # A
  def dispatch(state, mutator, {:A, operand, args})
      when operand in [:I, :Q, :F, :S, :D, :T, :C] do
    result = mutator.get(state, :RLO) &&& mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  # AN
  def dispatch(state, mutator, {:AN, operand, args})
      when operand in [:I, :Q, :F, :S, :D, :T, :C] do
    result = mutator.get(state, :RLO) &&& ~~~mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  # O
  def dispatch(state, mutator, {:O, operand, args})
      when operand in [:I, :Q, :F, :S, :D, :T, :C] do
    result = mutator.get(state, :RLO) ||| mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  # ON
  def dispatch(state, mutator, {:ON, operand, args})
      when operand in [:I, :Q, :F, :S, :D, :T, :C] do
    result = mutator.get(state, :RLO) ||| ~~~mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  # S
  def dispatch(state, mutator, {:S, operand, args})
      when operand in [:I, :Q, :F, :S, :D] do
    rlo = mutator.get(state, :RLO)

    if rlo == 1 do
      mutator.set(state, operand, args, 1)
    else
      state
    end
  end

  # R
  def dispatch(state, mutator, {:R, operand, args})
      when operand in [:I, :Q, :F, :S, :D] do
    rlo = state |> mutator.get(:RLO)

    if rlo == 1 do
      mutator.set(state, operand, args, 0)
    else
      state
    end
  end

  # =
  def dispatch(state, mutator, {:assign, operand, args})
      when operand in [:I, :Q, :F, :S, :D] do
    state.set(state, operand, args, state |> state.get(:RLO))
  end

  # L
  # L IB/QB/FY/SY
  def dispatch(state, mutator, {:L, operand, args})
      when operand in [:IB, :QB, :FY, :SY, :PY, :OY] do
    byte = mutator.get(state, operand, args)

    state
    |> mutator.set(:ACCU_1_L, byte)
  end

  # L T/C
  def dispatch(state, mutator, {:L, operand, args})
      when operand in [:C, :T] do
    word = mutator.get(state, operand, args)
    state |> mutator.set(:ACCU_1_L, word)
  end

  # L IW/QW/FW/SW/PW/OW
  def dispatch(state, mutator, {:L, operand, args})
      when operand in [:IW, :QW, :FW, :SW, :PW, :OW] do
    word = mutator.get(state, operand, args)

    b0 = (word &&& 0xFF) <<< 8
    b1 = (word &&& 0xFF) >>> 8

    state |> mutator.set(:ACCU_1_L, b0 + b1)
  end
end
