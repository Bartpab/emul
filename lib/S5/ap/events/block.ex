defmodule Emulation.S5.Events.BlockEventProcessor do
  alias Emulation.Common.PushdownAutomaton, as: PA
  alias Emulation.S5.AP.StateDispatcher, as: State

  def process_event(state, event) do
    case event do
      {:BLOCK_CALL, {_, _, nature}} ->
        case nature do
          :internal ->
            state
            |> PA.push([:ap, :exe], :INTERPRET)

          :external ->
            state
            |> PA.push([:ap, :exe], :EXTERNAL)
        end

      {:BLOCK_RETURN, _} ->
        state |> PA.pop([:ap, :exe], :BLOCK_RETURN)

      {:WRITE_BLOCK, {type, id, instrs}} ->
        state |> State.write_block(type, id, instrs)

      _ ->
        state
    end
  end
end
