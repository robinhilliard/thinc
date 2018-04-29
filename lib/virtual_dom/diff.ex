defmodule VirtualDOM.Diff do
  @moduledoc false


  def diff({:vnode, _, _, _, _, nh, th}, {:vnode, _, _, _, _, nh, th}) do
    []
  end

  def diff({:vnode, _, _, _, _, na, th}, {:vnode, _, _, _, _, nb, th}) do
    []
  end



end
