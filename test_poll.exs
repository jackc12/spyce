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

  describe "disable" do
    test "sets enabled?=false" do
      assert Poll.get_state().enabled? === true
      Poll.disable()
      assert Poll.get_state.enabled? === false
    end
    test "stops polling" do
      assert_received :tick

      # because time isn't mocked
      assert_receive :poll, 2000
      Poll.disable()
      assert_receive :tick, 2000
      refute_receive :poll, 2000
    end
  end
end
