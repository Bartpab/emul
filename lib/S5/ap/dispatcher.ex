defmodule Emulation.S5.Dispatcher do
  use Bitwise

  def reverse(value, size, chunk \\ 8) do
    Emulation.Common.Utils.adjust([value], size, chunk)
    |> Enum.reverse()
    |> Emulation.Common.Utils.adjust(chunk, size)
    |> Enum.fetch!(0)
  end

  # SHOW
  def dispatch(state, mutator, {:SHOW, operand, args}) do
    value = state |> mutator.get(operand, args)

    case operand do
      :T ->
        {{slice, unit}, remaining} = Emulation.S5.AP.Services.Timers.read(value)
        IO.puts("#{remaining} (#{slice} #{unit})")

      _ ->
        IO.inspect(value)
    end

    state
  end

  def sup(value) do
    if value > 0 do
      1
    else
      0
    end
  end

  # A
  def dispatch(state, mutator, {:A, operand, args})
      when operand in [:I, :Q, :F, :S, :D] do
    result = mutator.get(state, :RLO) &&& mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  def dispatch(state, mutator, {:A, operand, args})
      when operand in [:T, :C] do
    result = mutator.get(state, :RLO) &&& mutator.get(state, operand, args) |> sup
    state |> mutator.set(:RLO, result)
  end

  # AN
  def dispatch(state, mutator, {:AN, operand, args})
      when operand in [:I, :Q, :F, :S, :D] do
    result = mutator.get(state, :RLO) &&& ~~~mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  def dispatch(state, mutator, {:AN, operand, args})
      when operand in [:T, :C] do
    result = mutator.get(state, :RLO) &&& ~~~(mutator.get(state, operand, args) |> sup)
    state |> mutator.set(:RLO, result)
  end

  # O
  def dispatch(state, mutator, {:O, operand, args})
      when operand in [:I, :Q, :F, :S, :D] do
    result = mutator.get(state, :RLO) ||| mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  def dispatch(state, mutator, {:O, operand, args})
      when operand in [:T, :C] do
    result = mutator.get(state, :RLO) ||| mutator.get(state, operand, args) |> sup
    state |> mutator.set(:RLO, result)
  end

  # ON
  def dispatch(state, mutator, {:ON, operand, args})
      when operand in [:I, :Q, :F, :S, :D] do
    result = mutator.get(state, :RLO) ||| mutator.get(state, operand, args)
    state |> mutator.set(:RLO, ~~~result)
  end

  def dispatch(state, mutator, {:ON, operand, args})
      when operand in [:T, :C] do
    result = mutator.get(state, :RLO) ||| mutator.get(state, operand, args) |> sup
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
    |> mutator.set(:RLO, 0)
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
    |> mutator.set(:RLO, 0)
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
    timer_id = args |> Enum.fetch!(0)
    timer_value = state |> mutator.get(:ACCU_1_L)

    if state |> mutator.get_edge(:RLO) == :raising do
      state |> Emulation.S5.AP.Services.Timers.activate(timer_id, timer_value)
    else
      state
    end
    |> mutator.set(:RLO, 0)
  end

  # SE
  def dispatch(state, mutator, {:SE, :T, args}) do
    timer_id = args |> Enum.fetch!(0)
    timer_value = state |> mutator.get(:ACCU_1_L)

    if state |> mutator.get_edge(:RLO) == :raising do
      state |> Emulation.S5.AP.Services.Timers.activate(timer_id, timer_value)
    else
      state
    end
    |> mutator.set(:RLO, 0)
  end

  # SD
  def dispatch(state, mutator, {:SD, :T, args}) do
    timer_id = args |> Enum.fetch!(0)
    timer_value = state |> mutator.get(:ACCU_1_L)

    if state |> mutator.get_edge(:RLO) == :raising do
      state |> Emulation.S5.AP.Services.Timers.activate(timer_id, timer_value)
    else
      state
    end
    |> mutator.set(:RLO, 0)
  end

  # SS
  def dispatch(state, mutator, {:SS, :T, args}) do
    timer_id = args |> Enum.fetch!(0)
    timer_value = state |> mutator.get(:ACCU_1_L)

    if state |> mutator.get_edge(:RLO) == :raising do
      state |> Emulation.S5.AP.Services.Timers.activate(timer_id, timer_value)
    else
      state
    end
    |> mutator.set(:RLO, 0)
  end

  # SF
  def dispatch(state, mutator, {:SF, :T, args}) do
    timer_id = args |> Enum.fetch!(0)
    timer_value = state |> mutator.get(:ACCU_1_L)

    if state |> mutator.get_edge(:RLO) == :raising do
      state |> Emulation.S5.AP.Services.Timers.activate(timer_id, timer_value)
    else
      state
    end
    |> mutator.set(:RLO, 0)
  end

  # R
  def dispatch(state, mutator, {:R, :T, args}) do
    timer_id = args |> Enum.fetch!(0)

    if state |> mutator.get_edge(:RLO) == :raising do
      state |> Emulation.S5.AP.Services.Timers.reset(timer_id)
    else
      state
    end
    |> mutator.set(:RLO, 0)
  end

  # CU
  def dispatch(state, mutator, {:CU, :T, args}) do
    counter = mutator.get(state, :T, args) + 1
    state |> mutator.set(:T, args, counter)
  end

  # CD
  def dispatch(state, mutator, {:CD, :T, args}) do
    counter = mutator.get(state, :T, args) - 1
    state |> mutator.set(:T, args, counter)
  end

  # S
  def dispatch(state, mutator, {:S, :C, args}) do
    counter = state |> mutator.get(:ACCU_1_L)
    state |> mutator.set(:T, args, counter) |> mutator.set(:RLO, 0)
  end

  # S
  def dispatch(state, mutator, {:R, :C, args}) do
    state |> mutator.set(:T, args, 0) |> mutator.set(:RLO, 0)
  end

  def store_f_result(state, mutator, value) do
    state
    |> mutator.set(:ACCU_1, value)
    |> mutator.set(:ACCU_2_L, mutator.get(state, :ACCU_3_L))
    |> mutator.set(:ACCU_3_L, mutator.get(state, :ACCU_4_L))
  end

  # +F
  def dispatch(state, mutator, {:"+F", _, _}) do
    v1 = state |> mutator.get(:ACCU_1_L)
    v2 = state |> mutator.get(:ACCU_2_L)

    {status, v} = Emulation.Common.FixedPointWord.add(v1, v2)

    state
    |> store_f_result(mutator, v)
  end

  # -F
  def dispatch(state, mutator, {:"-F", _, _}) do
    v1 = state |> mutator.get(:ACCU_1_L)
    v2 = state |> mutator.get(:ACCU_2_L)

    {status, v} = Emulation.Common.FixedPointWord.substract(v1, v2)

    state
    |> store_f_result(mutator, v)
  end

  # xF
  def dispatch(state, mutator, {:xF, _, _}) do
    v1 = state |> mutator.get(:ACCU_1_L)
    v2 = state |> mutator.get(:ACCU_2_L)

    {status, v} = Emulation.Common.FixedPointWord.multiply(v1, v2)

    state
    |> store_f_result(mutator, v)
  end

  # :F
  def dispatch(state, mutator, {:":F", _, _}) do
    v1 = state |> mutator.get(:ACCU_1_L)
    v2 = state |> mutator.get(:ACCU_2_L)

    {result, remainder} = Emulation.Common.FixedPointWord.divide(v1, v2)

    v = (remainder <<< 16) + result

    state
    |> store_f_result(mutator, v)
  end

  def store_g_result(state, mutator, value) do
    state
    |> mutator.set(:ACCU_1, value)
    |> mutator.set(:ACCU_2, mutator.get(state, :ACCU_3))
    |> mutator.set(:ACCU_3, mutator.get(state, :ACCU_4))
  end

  # +G
  def dispatch(state, mutator, {:"+G", _, _}) do
    v1 = state |> mutator.get(:ACCU_1)
    v2 = state |> mutator.get(:ACCU_2)

    v = Emulation.Common.FP32.add(v1, v2)

    state
    |> store_g_result(mutator, v)
  end

  # -G
  def dispatch(state, mutator, {:"-G", _, _}) do
    v1 = state |> mutator.get(:ACCU_1)
    v2 = state |> mutator.get(:ACCU_2)

    v = Emulation.Common.FP32.substract(v1, v2)

    state
    |> store_g_result(mutator, v)
  end

  # xG
  def dispatch(state, mutator, {:xG, _, _}) do
    v1 = state |> mutator.get(:ACCU_1)
    v2 = state |> mutator.get(:ACCU_2)

    v = Emulation.Common.FP32.multiply(v1, v2)

    state
    |> store_g_result(mutator, v)
  end

  # :G
  def dispatch(state, mutator, {:":G", _, _}) do
    v1 = state |> mutator.get(:ACCU_1)
    v2 = state |> mutator.get(:ACCU_2)

    v = Emulation.Common.FP32.divide(v1, v2)

    state
    |> store_g_result(mutator, v)
  end

  # !=G (equal)
  def dispatch(state, mutator, {:"!=G", _, _}) do
    v1 = state |> mutator.get(:ACCU_2)
    v2 = state |> mutator.get(:ACCU_1)

    state
    |> mutator.set(:RLO, Emulation.Common.FP32.eq(v1, v2))
  end

  # ><G (not equal)
  def dispatch(state, mutator, {:"><G", _, _}) do
    v1 = state |> mutator.get(:ACCU_2)
    v2 = state |> mutator.get(:ACCU_1)

    state
    |> mutator.set(:RLO, Emulation.Common.FP32.neq(v1, v2))
  end

  # >G (greater than)
  def dispatch(state, mutator, {:">G", _, _}) do
    v1 = state |> mutator.get(:ACCU_2)
    v2 = state |> mutator.get(:ACCU_1)

    state
    |> mutator.set(:RLO, Emulation.Common.FP32.gt(v1, v2))
  end

  # >=G (greater than or equal)
  def dispatch(state, mutator, {:"=>G", _, _}) do
    v1 = state |> mutator.get(:ACCU_2)
    v2 = state |> mutator.get(:ACCU_1)

    state
    |> mutator.set(:RLO, Emulation.Common.FP32.gte(v1, v2))
  end

  # <G (lower than)
  def dispatch(state, mutator, {:"<G", _, _}) do
    v1 = state |> mutator.get(:ACCU_2)
    v2 = state |> mutator.get(:ACCU_1)

    state
    |> mutator.set(:RLO, Emulation.Common.FP32.lt(v1, v2))
  end

  # =<G (lower than or equal)
  def dispatch(state, mutator, {:"=<G", _, _}) do
    v1 = state |> mutator.get(:ACCU_2)
    v2 = state |> mutator.get(:ACCU_1)

    state
    |> mutator.set(:RLO, Emulation.Common.FP32.lte(v1, v2))
  end

  # JU Jump
  def dispatch(state, mutator, {:JU, operand, [id]})
      when operand in [:PB, :FB, :SB, :OB] do
    state |> mutator.call(operand, id)
  end

  # JC Jump Conditional
  # 
  def dispatch(state, mutator, {:JC, operand, [id]})
      when operand in [:PB, :FB, :SB, :OB] do
    if mutator.get(state, :RLO) do
      state |> mutator.call(operand, id)
    else
      state
    end
  end

  # Call Data Block (C)
  # Call a data block
  def dispatch(state, mutator, {:C, :DB, [id]}) do
    state |> mutator.open(:DB, id)
  end

  # Call Extended Data Block (CX)
  # Call an extended data block
  def dispatch(state, mutator, {:CX, :DX, [id]}) do
    state |> mutator.open(:DX, id)
  end

  # Generate a Block (G)
  # Generate a data block. The number of its data
  # words must be stored in ACCU 1 (max. 4091 DW)
  def dispatch(state, mutator, {:G, :DB, [id]}) do
    size = state |> mutator.get(:ACCU_1)
    state |> mutator.generate_block(:DB, id, size)
  end

  # Generate a Block (GX)
  # Generate an extended data block. The number of
  # its data words must be stored in ACCU 1 (max.
  # 4091 DW)
  def dispatch(state, mutator, {:GX, :DX, [id]}) do
    size = state |> mutator.get(:ACCU_1)
    state |> mutator.generate_block(:DX, id, size)
  end

  # BE
  # Block end (termination of a block)
  def dispatch(state, mutator, {:BE, _, _}) do
    state |> mutator.return
  end

  # BEU
  # Block end, unconditional
  def dispatch(state, mutator, {:BEU, _, _}) do
    state |> mutator.return
  end

  # BEC
  # Block end, conditional (if RLO is "1")
  def dispatch(state, mutator, {:BEC, _, _}) do
    if mutator.get(state, :RLO) do
      state |> mutator.return
    else
      state
    end
  end

  # NOP 0
  # No operation (all bits set to 0)
  def dispatch(state, _mutator, {:NOP_0, _, _}) do
    state
  end

  # NOP 1
  # No operation (all bits set to 1)
  def dispatch(state, _mutator, {:NOP_1, _, _}) do
    state
  end

  # STOP signal
  # Direct transition to "STOP" mode
  def dispatch(state, mutator, {:STP, _, _}) do
    state |> mutator.stop
  end

  # A=
  # AND operation: scan a formal operand for "1"
  # (parameter type: I, Q, T, C; data type: BI)

  def dispatch(state, mutator, {:"A=", operand, [_bit, _addr] = args})
      when operand in [:I, :Q, :F, :S, :D] do
    result = 1 &&& mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  def dispatch(state, mutator, {:"A=", operand, [_addr] = args})
      when operand in [:T, :C] do
    result = 1 &&& mutator.get(state, operand, args) |> sup
    state |> mutator.set(:RLO, result)
  end

  # AN=
  # AND operation: scan a formal operand for "0"
  # (parameter type: I, Q, T, C; data type: BI)

  def dispatch(state, mutator, {:"AN=", operand, [_bit, _addr] = args})
      when operand in [:I, :Q, :F, :S, :D] do
    result = ~~~(1 &&& mutator.get(state, operand, args)) &&& 1
    state |> mutator.set(:RLO, result)
  end

  def dispatch(state, mutator, {:"AN=", operand, [_addr] = args})
      when operand in [:T, :C] do
    result = ~~~(1 &&& mutator.get(state, operand, args) |> sup) &&& 1
    state |> mutator.set(:RLO, result)
  end

  # O=
  # OR operation: scan a formal operand for "1"
  # (parameter type: I, Q, T, C; data type: BI)

  def dispatch(state, mutator, {:"O=", operand, [_bit, _addr] = args})
      when operand in [:I, :Q, :F, :S, :D] do
    result = 1 ||| mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  def dispatch(state, mutator, {:"O=", operand, [_addr] = args})
      when operand in [:T, :C] do
    result = 1 ||| mutator.get(state, operand, args) |> sup
    state |> mutator.set(:RLO, result)
  end

  # ON=
  # OR operation: scan a formal operand for "0"
  # (parameter type: I, Q, T, C; data type: BI)

  def dispatch(state, mutator, {:"ON=", operand, [_bit, _addr] = args})
      when operand in [:I, :Q, :F, :S, :D] do
    result = ~~~(1 ||| mutator.get(state, operand, args)) &&& 1
    state |> mutator.set(:RLO, result)
  end

  def dispatch(state, mutator, {:"ON=", operand, [_addr] = args})
      when operand in [:T, :C] do
    result = ~~~(1 ||| mutator.get(state, operand, args) |> sup) &&& 1
    state |> mutator.set(:RLO, result)
  end

  # AW
  def dispatch(state, mutator, {:AW, _, _}) do
    acc1 = state |> mutator.get(:ACCU_1)
    acc2 = state |> mutator.get(:ACCU_2)

    state |> mutator.set(:ACCU_1, acc1 &&& acc2)
  end

  # OW
  def dispatch(state, mutator, {:OW, _, _}) do
    acc1 = state |> mutator.get(:ACCU_1)
    acc2 = state |> mutator.get(:ACCU_2)

    state |> mutator.set(:ACCU_1, acc1 ||| acc2)
  end

  # XOW
  def dispatch(state, mutator, {:XOW, _, _}) do
    acc1 = state |> mutator.get(:ACCU_1)
    acc2 = state |> mutator.get(:ACCU_2)

    state |> mutator.set(:ACCU_1, acc1 ^^^ acc2)
  end

  # TB
  def dispatch(state, mutator, {:TB, operand, [_bit, _id] = args})
      when operand in [:I, :Q, :F, :D, :RI, :RJ, :RS, :RT, :T, :C] do
    result = 1 &&& mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  # TBN
  def dispatch(state, mutator, {:TBN, operand, [_bit, _id] = args})
      when operand in [:I, :Q, :F, :D, :RI, :RJ, :RS, :RT, :T, :C] do
    result = 1 ^^^ mutator.get(state, operand, args)
    state |> mutator.set(:RLO, result)
  end

  # SU
  def dispatch(state, mutator, {:SU, operand, [_bit, _id] = args})
      when operand in [:I, :Q, :F, :D, :RI, :RJ, :T, :C] do
    state |> mutator.set(operand, args, 1)
  end

  # RU
  def dispatch(state, mutator, {:RU, operand, [_bit, _id] = args})
      when operand in [:I, :Q, :F, :D, :RI, :RJ, :T, :C] do
    state |> mutator.set(operand, args, 0)
  end
end
