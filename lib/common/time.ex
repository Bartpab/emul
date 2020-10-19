defmodule Emulations.Common.Time do
    def convert(value, from, to) do
        case {from, to} do
            {:millisecond, :microsecond} -> value * 100
            {same, same} -> value
            _ -> raise "Not implemented #{from} to #{to}"
        end
    end

    def compare(t1, t0) do
        cond do
            t1 > t0 -> :gt
            t1 < t0 -> :lt
            t1 == t0 -> :eq
        end
    end
end