defmodule Emulation.S5.Events.BlockEventProcessor do
  alias Emulation.Common.PushdownAutomaton, as: PA

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

      _ ->
        state
    end
  end
end
