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

    assert diff(a, b) == [{:set_text, [], :__text__, "ben"}]
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

    assert diff(a, b) == [{:del_attr, [], :class, :__no_val__}]
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


  test "1st level child text add" do
    a = view do
      div do
        img src: "c172"
      end
    end

     b = view do
      div do
        img src: "c172"
        text "A Cessna 172"
      end
    end

    assert diff(a, b) == [{:set_text, [1], :__text__, "A Cessna 172"}]
  end


  test "1st level child text change" do
    a = view do
      div do
        img src: "c172"
        text "A Cessna 17"
      end
    end

     b = view do
      div do
        img src: "c172"
        text "A Cessna 172"
      end
    end

    assert diff(a, b) == [{:set_text, [1], :__text__, "A Cessna 172"}]
  end


  test "1st level child swap" do
    a = view do
      div do
        img src: "c172"
        text "A Cessna 172"
      end
    end

     b = view do
      div do
        text "A Cessna 172"
        img src: "c172"
      end
    end

    assert diff(a, b) == [{:move, [1], 0, "A Cessna 172"}]
  end


  test "1st level child swap with duplicate" do
    a = view do
      div do
        img src: "c172"
        text "A Cessna 172"
        img src: "c172"
        text "A Cessna 172"
      end
    end

     b = view do
      div do
        text "A Cessna 172"
        img src: "c172"
        img src: "c172"
        text "A Cessna 172"
      end
    end

    assert diff(a, b) == [{:move, [1], 0, "A Cessna 172"}]
  end


  test "1st level child swap with one delete" do
    a = view do
      div do
        img src: "c172"
        text "A Cessna 172"
        img src: "c172"
        text "A Cessna 172"
      end
    end

     b = view do
      div do
        text "A Cessna 172"
        img src: "c172"
        img src: "c172"
      end
    end

    assert diff(a, b) == [{:move, [1], 0, "A Cessna 172"}]
  end

  test "1st level child swap with two deletes" do
    a = view do
      div do
        img src: "c172"
        text "A Cessna 172"
        img src: "c172"
        text "A Cessna 172"
      end
    end

     b = view do
      div do
        text "A Cessna 172"
        img src: "c172"
      end
    end

    assert diff(a, b) == [{:move, [1], 0, "A Cessna 172"}]
  end
end
