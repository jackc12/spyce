defmodule Poll do
  use GenServer

  @interval :timer.seconds(1)

  # --- Client API ---

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def enable(), do: GenServer.cast(__MODULE__, :enable)

  def disable(), do: GenServer.cast(__MODULE__, :disable)

  # --- Server Callbacks ---

  @impl true
  def init(_opts) do
    # Poll immediately on startup; change to @interval to delay the first run
    schedule_poll(0)
    {:ok, %{poll?: true}}
  end

  @impl true
  def handle_cast(:enable, state), do: %{state | poll?: true}
  @impl true
  def handle_cast(:disable, state), do: %{state | poll?: true}

  @impl true
  def handle_info(:poll, state) do
    if state.poll?, do: perform_poll()
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
    Process.send_after(__MODULE__, :poll, delay)
  end

  defp perform_poll() do
    do_perform_poll()
    |> Enum.each(&write/1)
  end

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
    rescue error -> IO.puts("Oh no there was an error! error=#{inspect(error)}")
    :ok



  end

  defp do_write(order) do
    # omitting context functions for brevity
    # upsert_order(order)
    if Process.whereis(:test), do: send(:test, {:order_upsert, order})
    :ok
  end
end
