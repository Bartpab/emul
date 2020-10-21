defmodule Emulation.S5.STL do
  def load(filepath) do
    {:ok, content} = File.read(filepath)
    {:ok, tokens, _} = :s5_stl_lexer.string(content |> String.to_charlist())
    :s5_stl_parser.parse(tokens)
  end

  def parse(content) do
    {:ok, tokens, _} = :s5_stl_lexer.string(content)
    :s5_stl_parser.parse(tokens)
  end
end
