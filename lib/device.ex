defmodule Emulation.Device do
  alias Emulation.Device

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

  def id(state) do
    state[:device][:id]
  end

  def new(device_id) do
    %{
      device: %{
        id: device_id,
        mode: :RUN,
        timeslice: {
          16,
          :millisecond
        },
        last_updated: DateTime.utc_now(),
        tick: DateTime.utc_now()
      }
    }
  end

  def process_message(state, msg, from) do
    case msg do
      :DEVICE_STOP ->
        state = state |> Device.set_mode(:DEVICE_STOP)
        {:pass, state}

      :DISPLAY_STATE ->
        IO.inspect(state)
        {:pass, state}

      _ ->
        state = Emulation.Emulator.State.push(state, msg)
        {:pass, state}
    end
  end

  defmacro __using__(_) do
    quote do
      require Logger

      use Task, restart: :temporary
      use Emulation.COM
      use Emulation.Emulator

      alias Emulation.Device

      def start_link({id, opts} = arg) do
        Task.start_link(__MODULE__, :run, [arg])
      end

      def run({id, opts}) do
        %{}
        |> Map.merge(Emulation.Device.new(id))
        |> Map.merge(Emulation.COM.new())
        |> Map.merge(Emulation.Emulator.State.new())
        |> start(opts)
        |> init
        |> loop
      end

      def loop(state) do
        {timeout, unit} = state[:device][:timeslice]

        unless state |> Device.mode() == :DEVICE_STOP do
          state =
            state
            |> poll_messages(timeout)
            |> dispatch_messages(&Device.process_message/3)
            |> update
            |> commit_messages()
            |> loop
        else
          state
        end
      end

      def update(state, remaining) do
        {slice, unit} = state[:device][:timeslice]

        unless remaining < slice do
          left = remaining - slice
          tick = DateTime.add(state[:device][:tick], slice, unit)

          t0 = DateTime.utc_now()

          state =
            state
            |> put_in([:device, :tick], tick)
            |> frame({slice, unit})

          t1 = DateTime.utc_now()

          elapsed = DateTime.diff(t1, t0, unit)

          unless elapsed <= slice do
            Logger.warn(
              "[#{state |> Device.id()}] Time overflow: #{elapsed} instead of #{slice} #{unit}."
            )
          end

          state |> update(left)
        else
          state
        end
      end

      def update(state) do
        now = DateTime.utc_now()
        last_updated = get_in(state, [:device, :last_updated])
        {_, unit} = state[:device][:timeslice]
        remaining = DateTime.diff(now, last_updated, unit)

        state
        |> update(remaining)
        |> put_in([:device, :last_updated], state[:device][:tick])
      end
    end
  end
end
