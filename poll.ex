defmodule Poll do
  use GenServer

  @moduledoc """
  start by running 
  Poll.start_link()

  should see orders being upserted into db
  enable/disable using
  Poll.enable()

  check status using
  Poll.status()
  """

  # should actually mock this for testing
  @interval :timer.seconds(1)

  # --- Client API ---

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def stop(), do: GenServer.stop(Poll)

  def enable(), do: GenServer.cast(__MODULE__, :enable)

  def disable(), do: GenServer.cast(__MODULE__, :disable)

  def get_state(), do: GenServer.call(__MODULE__, :get_state)

  # --- Server Callbacks ---

  @impl true
  def init(_opts) do
    # Poll immediately on startup; change to @interval to delay the first run
    schedule_poll(0)
    # ran_at with list of DateTime.utc_now is probably more useful than just integer 
    # could also just get this from the updated_at field in the db
    # just wanted a way to show the polls are actually happening in the state
    {:ok, %{enabled?: true, frequency: 0}}
  end

  @impl true
  def handle_call(:get_state, _from, state), do: {:reply, state, state}

  @impl true
  def handle_cast(:enable, state), do: {:noreply, %{state | enabled?: true}}
  @impl true
  def handle_cast(:disable, state), do: {:noreply, %{state | enabled?: false}}

  @impl true
  def handle_info(:poll, state) do
    state = if state.enabled?, do: perform_poll(state), else: state
    schedule_poll(@interval)
    {:noreply, state}
  end

  # Catch-all for unexpected messages
  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  # --- Helpers ---

  defp schedule_poll(delay) do
    # because I didn't want to mock time
    send_test(:tick)
    Process.send_after(__MODULE__, :poll, delay)
  end

  defp perform_poll(%{enabled?: true} = state) do
    do_perform_poll()
    |> Enum.each(&write/1)

    %{state | frequency: state.frequency + 1}
  end

  defp perform_poll(state), do: state

  defp do_perform_poll(),
    do: [
      %{order_number: 0, name: "pizza"},
      %{order_number: 1, name: "pasta"}
    ]

  defp write(order) do
    # considered doing:
    # Task.start(&do_write/1)
    # advantages are fire and forget prevents early failure from blocking later writes
    # concurrency is cool but limited by the db connection pool
    # caveat: could overwhelm db connection pool
    # so just went with try

    do_write(order)
  rescue
    error ->
      IO.puts("Oh no there was an error! error=#{inspect(error)}")
      :ok
  end

  defp do_write(order) do
    # omitting context functions for brevity
    # upsert_order(order)
    IO.puts("upserted order=#{inspect(order)}")
    :ok
  end

  def send_test(message), do: if(Process.whereis(:test), do: send(:test, message))
end
