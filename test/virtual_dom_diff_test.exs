defmodule VirtualDOMDiffTest do
  use ExUnit.Case
  import VirtualDOM.VNode
  import VirtualDOM.Diff


  test "single html node identity" do
    a = vnode "html"
    assert diff(a, a) == []
  end


  test "single text node identity" do
    a = view do
      text "identity"
    end

    assert diff(a, a) == []
  end


  test "single text node replace" do
    a = view do
      text "bill"
    end

    b = view do
      text "ben"
    end

    assert diff(a, b) == [{:set_text, [], "ben"}]
  end


  test "single node with attribute identity" do
    a = view do
      div class: "identity"
    end

    assert diff(a, a) == []
  end


  test "single attr replace" do
    a = view do
      div class: "bill"
    end

    b = view do
      div class: "ben"
    end

    assert diff(a, b) == [{:set_attr, [], :class, "ben"}]
  end


    test "single attr add" do
    a = view do
      div
    end

    b = view do
      div class: "ben"
    end

    assert diff(a, b) == [{:set_attr, [], :class, "ben"}]
  end


  test "single attr remove" do
    a = view do
      div class: "bill"
    end

    b = view do
      div
    end

    assert diff(a, b) == [{:del_attr, [], :class}]
  end


  test "multiple attr replace" do
    a = view do
      img class: "a_class", src: "a_src"
    end

    b = view do
      img class: "b_class", src: "b_src"
    end

    assert diff(a, b) ==
      [{:set_attr, [], :class, "b_class"}, {:set_attr, [], :src, "b_src"}]
  end

end
