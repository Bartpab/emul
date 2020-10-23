defmodule Emulation.S5.AP.Services.Timers do
  use Bitwise
  alias Emulation.S5.AP.StateDispatcher, as: State

  def get_running_timers(state) do
    timers = state |> State.take_area!(:T)
    rec_get_running_timers(timers, 0)
  end

  def rec_get_running_timers(timers, index \\ 0) do
    case timers do
      [timer | tail] ->
        {_, remaining} = read(timer)

        if remaining > 0 do
          [index]
        else
          []
        end ++ rec_get_running_timers(tail, index + 1)

      [] ->
        []
    end
  end

  def write(tb, remaning) do
    Emulation.Common.Utils.to_bcd(remaning |> trunc) +
      (case tb do
         {0.01, :second} -> 0
         {0.1, :second} -> 1
         {1, :second} -> 2
         {10, :second} -> 3
       end <<< 12)
  end

  def read(timer) do
    tb =
      case timer &&& 0x3000 do
        0 -> {0.01, :second}
        1 -> {0.1, :second}
        2 -> {1, :second}
        3 -> {10, :second}
      end

    remaining = Emulation.Common.Utils.from_bcd(timer, 3)

    {tb, remaining}
  end

  def process(state) do
    timer_ids = get_running_timers(state)
    state |> process(timer_ids)
  end

  def process(state, timer_ids) do
    case timer_ids do
      [timer_id | tail] ->
        state
        |> process_timer(timer_id)
        |> process(tail)

      [] ->
        state
    end
  end

  def process_timer(state, timer_id) do
    timers = state |> State.take_area!(:T)

    {{slice, unit}, remaining} =
      timers
      |> Enum.fetch!(timer_id)
      |> read

    now =
      state
      |> State.now()

    tick =
      state
      |> State.get_timer_last_tick(timer_id)

    dt = (now - tick) |> Emulations.Common.Time.convert(:microsecond, unit)

    if dt >= slice do
      step = (dt / slice) |> trunc
      remaining = remaining - step

      remaining =
        if remaining <= 0 do
          0
        else
          remaining
        end

      encoded_timer = write({slice, unit}, remaining)

      timers =
        timers
        |> List.replace_at(timer_id, encoded_timer)

      state
      |> State.set_timer_last_tick(timer_id, now)
      |> State.write_area!(:T, timers)
    else
      state
    end
  end

  def reset(state, timer_id) do
    activate(state, timer_id, 0)
  end

  def activate(state, timer_id, remaining) do
    timers = state |> State.take_area!(:T)
    {tb, _} = timers |> Enum.fetch!(timer_id) |> read

    encoded_timer = write(tb, remaining)

    state
    |> State.write_area!(:T, timers |> List.replace_at(timer_id, encoded_timer))
    |> State.set_timer_last_tick(timer_id, state |> State.now())
  end
end
