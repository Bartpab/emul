defmodule Emulation.S5.Errors.UnexistingBlockError do
  defexception message: "Block does not exist."
end

defmodule Emulation.S5.Errors.RewriteBlockError do
  defexception message: "The block cannot be rewritten."
end

defmodule Emulation.S5.Errors.MemoryExhaustedError do
  defexception message: "No more memory."
end
