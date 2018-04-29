defmodule VirtualDOMDiffTest do
  use ExUnit.Case
  import VirtualDOM.Diff


  test "plain list" do
    a = [1,2,3]
    b = [1,2,4]

    assert diff(a, b) == false
  end
end
