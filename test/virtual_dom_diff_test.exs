defmodule VirtualDOMDiffTest do
  use ExUnit.Case
  import VirtualDOM.VNode
  import VirtualDOM.Diff


  test "single html node identity" do
    a = vnode "html"

    assert diff(a, a) == []
  end
end
