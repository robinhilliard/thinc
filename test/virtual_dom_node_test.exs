defmodule VirtualDOMNodeTest do
  @moduledoc false


  use ExUnit.Case
  import VirtualDOM.VNode


  test "bare vnode" do
    assert {:vnode, "br", :__no_id__, %{}, [], _, _} =
      vnode "br"
  end


  test "bare tag" do
    assert {:vnode, "br", :__no_id__, %{}, [], _, _} =
    (
       view do
         br
       end
    )
  end


  test "tag with id" do
    assert {:vnode, "a", "anchor", %{}, [], _, _} =
    (
      view do
        a "anchor"
      end
    )
  end


  test "vnode with attributes" do
    assert {:vnode, "a", :__no_id__, %{:href => "there"}, [], _, _} =
             vnode "a", [href: "there"]
  end


  test "tag with attributes" do
    assert {:vnode, "a", :__no_id__, %{:href => "there"}, [], _, _} =
    (
      view do
        a href: "there"
      end
    )

  end


  test "vnode with one child" do
    assert {
            :vnode,
             "a",
             :__no_id__,
             %{},
             [
               {:vnode, "text", "Jimmy", %{}, [], _, _}
             ],
             _, _
           } = vnode "a", [vnode("text", "Jimmy")]
  end


  test "tag with one child" do
    assert {
            :vnode,
             "a",
             :__no_id__,
             %{},
             [
               {:vnode, "text", "Jimmy", %{}, [], _, _}
             ],
             _, _
           } =
    (
      view do
        a do
          text "Jimmy"
        end
      end
    )

  end


  test "tag with two children" do
    assert {
            :vnode,
             "a",
             :__no_id__,
             %{},
             [
               {:vnode, "text", "Jimmy", %{}, [], _, _},
               {:vnode, "text", "Alice", %{}, [], _, _}
             ],
             _, _
           } =
    (
      view do
        a do
          text "Jimmy"
          text "Alice"
        end
      end
    )

  end


  test "tag with attribute and child" do
    assert {
            :vnode,
            "div",
            :__no_id__,
            %{:style => "x"},
            [
              {
                :vnode,
                "p",
                :__no_id__,
                %{},
                [
                  {
                    :vnode,
                    "text",
                    "y",
                    %{}, [],
                    _, _
                  }
                ],
                _, _
              }
            ],
            _, _
           } =
    (
      view do
    div style: "x" do
          p do: text "y"
        end
      end
    )

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
