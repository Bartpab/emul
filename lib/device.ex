defmodule Emulators.Device do
  def set_mode(state, mode) do
    put_in(state, [:device, :mode], mode)
  end

  def mode(state) do
    get_in(state, [:device, :mode])
  end

  def idle(state) do
    state |> set_mode(:IDLE)
  end

  def run(state) do
    state |> set_mode(:RUN)
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
        start(opts)
        |> Map.merge(%{
          device: %{
            id: id,
            mode: :IDLE,
            timeslice: {
              5,
              :microsecond
            },
            last_tick: DateTime.utc_now()
          }
        })
        |> Map.merge(Emulators.COM.new())
        |> init
        |> loop
      end

      def loop(state) do
        state =
          state
          |> Emulators.COM.poll([], state |> Device.mode() == :IDLE)
          |> Emulators.COM.dispatch(&Device.process/3)
          |> update
          |> Emulators.COM.commit()
          |> put_in([:device, :last_tick], DateTime.utc_now())
          |> loop
      end

      def update(state, remaining) do
        {slice, unit} = state[:device][:timeslice]

        unless remaining < slice do
          state
          |> frame({slice, unit})
          |> update(remaining - slice)
        else
          state
        end
      end

      def update(state) do
        now = DateTime.utc_now()
        last_tick = get_in(state, [:device, :last_tick])
        {_, unit} = state[:device][:timeslice]
        remaining = DateTime.diff(now, last_tick, unit)
        state 
        |> update(remaining)
        |> Device.run
      end
    end
  end
end
