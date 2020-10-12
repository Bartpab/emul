defmodule Emulators.Device do
    def set_mode(state, mode) do
        put_in(state, [:device, :mode], mode)
    end

    def mode(state) do
      get_in(state, [:device, :mode])
    end

    def process(state, msg, from) do
        case msg do
            {:GET, :STATE} ->
                state = state |> Emulators.COM.send(from, {:STATE, state})
                {:pass, state}
            :PING ->
                state = state |> Emulators.COM.send(from, :PONG)
                {:pass, state}
            _ ->
                {:keep, state}
        end
    end

    defmacro __using__(_) do
        quote do
            use Task, restart: :temporary
            alias Emulators.Device

            def start_link({id, opts} = arg) do
                Task.start_link(__MODULE__, :run, [arg])
              end

            def run({id, opts}) do
                Emulators.Devices.bind(self(), id)

                start(opts)
                    |> Map.merge(%{device: %{id: id, mode: :IDLE}})
                    |> Map.merge(Emulators.COM.new())
                    |> init
                    |> loop
            end

            def loop(state) do
                state = state
                    |> Emulators.COM.poll([], state |> Device.mode == :IDLE)
                    |> Emulators.COM.dispatch(&Emulators.Device.process/3)
                    |> update
                    |> Emulators.COM.commit
                    |> Map.put(:last_tick, NaiveDateTime.utc_now)
                    |> loop
            end

            def update(state) do
                state |> frame
            end
        end
    end
end
