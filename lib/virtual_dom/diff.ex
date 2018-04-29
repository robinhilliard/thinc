defmodule VirtualDOM.Diff do
  @moduledoc false


  def diff(
        {:vnode, _, _, _, _, node_hash, tree_hash},
        {:vnode, _, _, _, _, node_hash, tree_hash}) do
    []  # Both hashes match, no changes
  end

  def diff(
        {:vnode, a_tag, a_id, a_attrs, _, a_node_hash, tree_hash},
        {:vnode, b_tag, b_id, b_attrs, _, b_node_hash, tree_hash}) do
    []
  end



end
