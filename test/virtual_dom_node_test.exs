defmodule VirtualDOMNodeTest do
  @moduledoc false


  use ExUnit.Case
  import VirtualDOM.VNode


  test "bare vnode" do
    v = vnode "br"
    assert v == {:vnode, "br", :noid, [], []}
  end


  test "bare tag" do
    v = view do
      br
    end

    assert v == {:vnode, "br", :noid, [], []}
  end


  test "tag with id" do
    v = view do
      a "anchor"
    end

    assert v == {:vnode, "a", "anchor", [], []}
  end


  test "vnode with attributes" do
    v = vnode "a", [href: "there"]
    assert v == {:vnode, "a", :noid, [href: "there"], []}
  end


  test "tag with attributes" do
    v = view do
      a href: "there"
    end

    assert v == {:vnode, "a", :noid, [href: "there"], []}
  end


  test "vnode with one child" do
    v = vnode "a", [vnode("text", "Jimmy")]
    assert v == {
            :vnode,
             "a",
             :noid,
             [],
             [
               {:vnode, "text", "Jimmy", [], []}
             ]
           }
  end


  test "tag with one child" do
    v = view do
      a do
        text "Jimmy"
      end
    end

    assert v == {
            :vnode,
             "a",
             :noid,
             [],
             [
               {:vnode, "text", "Jimmy", [], []}
             ]
           }

  end


  test "tag with two children" do
    v = view do
      a do
        text "Jimmy"
        text "Alice"
      end
    end

    assert v == {
            :vnode,
             "a",
             :noid,
             [],
             [
               {:vnode, "text", "Jimmy", [], []},
               {:vnode, "text", "Alice", [], []}
             ]
           }

  end


  test "tag with attribute and child" do
    v = view do
      div style: "x" do
        p do: text "y"
      end
    end

    assert v == {
            :vnode,
            "div",
            :noid,
            [style: "x"],
            [
              {
                :vnode,
                "p",
                :noid,
                [],
                [
                  {
                    :vnode,
                    "text",
                    "y",
                    [], []
                  }
                ]
              }
            ]}
  end


  test "vnode with invalid attrs" do
    assert_raise RuntimeError,
                 ~r/^List following vnode p must be either.*/,
                 fn ->
                   vnode "p", [1, 2, 3]
                 end
  end


  test "vnode with valid attrs and invalid children" do
    assert_raise RuntimeError,
                 ~r/Children of vnode p must all be vnodes/,
                 fn ->
                  vnode "p", [class: "x"], [1,2,3]
                 end
  end


  test "vnode with invalid attrs and valid children" do
    assert_raise RuntimeError,
                 ~r/Attributes of vnode p must be a keyword list/,
                 fn ->
                  vnode "p", [1, 2, 3], [vnode("text", "hello")]
                 end
  end


end
