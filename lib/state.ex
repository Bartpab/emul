defmodule Emulators.State do
    def new() do
        %{emulator: %{
            interrupt: nil
        }}
    end

   def has_interrupt(state) do
     state[:emulator][:interrupt] != nil
   end
 
   def get_interrupt(state) do
     get_in(state, [:emulator, :interrupt])
   end
 
   def interrupt(state, interrupt) do
     put_in(state, [:emulator, :interrupt], interrupt)
   end
   
   def clear_interrupt(state) do
     state |> interrupt(nil)
   end 
 end