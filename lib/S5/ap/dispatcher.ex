defmodule Emulation.S5.Dispatcher do
  use Bitwise

  def reverse(value, size, chunk \\ 8) do
    Emulation.Common.Utils.adjust([value], size, chunk)
    |> Enum.reverse()
    |> Emulation.Common.Utils.adjust(chunk, size)
    |> Enum.fetch!(0)
  end

  # DBG
  def dispatch(state, _mutator, {:DBG, :no_operand, [value]}) do
    IO.puts(value)
    state
  end

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
    result = mutator.get(state, :RLO) ||| mutator.get(state, operand, args)
    state |> mutator.set(:RLO, ~~~result)
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
    state |> mutator.set(operand, args, state |> mutator.get(:RLO))
  end

  # L
  def dispatch(state, mutator, {:L, operand, args}) do
    value = state |> mutator.get(operand, args)

    case operand do
      :IB -> state |> mutator.set(:ACCU_1_L, value)
      :IW -> state |> mutator.set(:ACCU_1_L, reverse(value, 16))
      :ID -> state |> mutator.set(:ACCU_1, reverse(value, 32))
      :QB -> state |> mutator.set(:ACCU_1_L, value)
      :QW -> state |> mutator.set(:ACCU_1_L, reverse(value, 16))
      :QD -> state |> mutator.set(:ACCU_1, reverse(value, 32))
      :FY -> state |> mutator.set(:ACCU_1_L, value)
      :FW -> state |> mutator.set(:ACCU_1_L, reverse(value, 16))
      :FD -> state |> mutator.set(:ACCU_1, reverse(value, 32))
      :SY -> state |> mutator.set(:ACCU_1_L, value)
      :SW -> state |> mutator.set(:ACCU_1_L, reverse(value, 16))
      :SD -> state |> mutator.set(:ACCU_1, reverse(value, 32))
      :DH -> state |> mutator.set(:ACCU_1, value)
      :DL -> state |> mutator.set(:ACCU_1_L, value)
      :DR -> state |> mutator.set(:ACCU_1_L, value)
      :DW -> state |> mutator.set(:ACCU_1_L, value)
      :DD -> state |> mutator.set(:ACCU_1, reverse(value, 32, 16))
      :KB -> state |> mutator.set(:ACCU_1_L, value)
      :KC -> state |> mutator.set(:ACCU_1_L, value)
      :KF -> state |> mutator.set(:ACCU_1_L, value)
      :KG -> state |> mutator.set(:ACCU_1_L, value)
      :KH -> state |> mutator.set(:ACCU_1_L, value)
      :KM -> state |> mutator.set(:ACCU_1_L, value)
      :KS -> state |> mutator.set(:ACCU_1_L, value)
      :KT -> state |> mutator.set(:ACCU_1_L, value)
      :KY -> state |> mutator.set(:ACCU_1_L, value)
      :PY -> state |> mutator.set(:ACCU_1_L, value)
      :PW -> state |> mutator.set(:ACCU_1_L, reverse(value, 16))
      :OY -> state |> mutator.set(:ACCU_1_L, value)
      :OW -> state |> mutator.set(:ACCU_1_L, reverse(value, 16))
      :T -> state |> mutator.set(:ACCU_1_L, value)
      :C -> state |> mutator.set(:ACCU_1_L, value)
    end
  end

  # LC
  def dispatch(state, mutator, {:LC, operand, args}) do
    value = state |> mutator.get(operand, args)

    case operand do
      :T -> state |> mutator.set(:ACCU_1_L, value)
      :C -> state |> mutator.set(:ACCU_1_L, value)
    end
  end

  # T
  def dispatch(state, mutator, {:T, operand, args}) do
    case operand do
      :IB -> state |> mutator.set(operand, args, state |> mutator.get(:ACCU_1_L))
      :IW -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1_L), 16))
      :ID -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1), 32))
      :QB -> state |> mutator.set(operand, args, state |> mutator.get(:ACCU_1_L))
      :QW -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1_L), 16))
      :QD -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1), 32))
      :FY -> state |> mutator.set(operand, args, state |> mutator.get(:ACCU_1_L))
      :FW -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1_L), 16))
      :FD -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1), 32))
      :SY -> state |> mutator.set(operand, args, state |> mutator.get(:ACCU_1_L))
      :SW -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1_L), 16))
      :SD -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1), 32))
      :DL -> state |> mutator.set(operand, args, state |> mutator.get(:ACCU_1_L))
      :DR -> state |> mutator.set(operand, args, state |> mutator.get(:ACCU_1_L))
      :DW -> state |> mutator.set(operand, args, state |> mutator.get(:ACCU_1))
      :DD -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1), 32, 16))
      :PY -> state |> mutator.set(operand, args, state |> mutator.get(:ACCU_1_L))
      :PW -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1_L), 16))
      :OY -> state |> mutator.set(operand, args, state |> mutator.get(:ACCU_1_L))
      :OW -> state |> mutator.set(operand, args, reverse(state |> mutator.get(:ACCU_1_L), 16))
    end
  end

  # SP
  def dispatch(state, mutator, {:SP, :T, args}) do
    _timer_id = args |> Enum.fetch!(0)
    _timer_value = state |> mutator.get(:ACCU_1_L)

    if state |> mutator.get_edge(:RLO) == :raising do
    end
  end

  # BE
  def dispatch(state, mutator, {:BE, _, _}) do
    state |> mutator.return
  end
end
