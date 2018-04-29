defmodule VirtualDOM.Diff do
  @moduledoc false

  require Enum


  def diff([], []) do
    []
  end

  def diff(a, b) do
    a == b
  end


  def is_flat(list) do
    Enum.all?(list, fn(x) -> !is_list(x) end)
  end

end
