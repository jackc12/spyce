# didn't think this warranted a whole mix project
ExUnit.start()
Code.require_file("poll.ex", __DIR__)

defmodule PollTest do
  use ExUnit.Case, async: true
  # did't want to mock time
  setup do 
    Process.register(self(), :test)
    Poll.start_link()
    :ok
  end

  describe "start_link" do
    setup do
      %{state: Poll.get_state()}
    end

    test "sets enabled?=true", %{state: state} do
      assert state.enabled? === true
      assert_received :tick
    end

    test "sets frequency=0", %{state: state} do
      assert state.frequency === 0
      assert_received :tick
    end
  end

  describe "get_state" do
    setup do
    end
  end
end
