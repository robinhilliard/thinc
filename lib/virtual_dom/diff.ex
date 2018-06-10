defmodule VirtualDOM.Diff do
  @moduledoc false

  import VirtualDOM.VNode, only: [tag_id_tree_hash: 1]
  import Enum, only: [flat_map: 2, group_by: 3, map: 2, reduce: 3, reverse: 1, with_index: 1]
  import Map, only: [keys: 1, merge: 2]


  def diff(
        a = {:vnode, _, _, _, _, _, _},
        b = {:vnode, _, _, _, _, _, _}) do
    diff([], a, b)
    |> map(
         fn {op, path, key, value} ->
           {op, reverse(path), key, value}  # Paths were in reverse order for append performance.
         end
       )
  end

  def diff(
        _,
        {:vnode, _, _, _, _, node_hash, children_hash},
        {:vnode, _, _, _, _, node_hash, children_hash}) do
    []  # Both hashes match, no changes
  end

  def diff(
        path,
        {:vnode, "text", _, _, _, a_node_hash, children_hash},
        {:vnode, "text", b_text, _, _, b_node_hash, children_hash}) when a_node_hash != b_node_hash do
    [{:set_text, path, :__text__, b_text}]  # Text is special case, we use id for text content
  end

  def diff(
        path,
        {:vnode, tag, id, a_attrs, _, a_node_hash, children_hash},
        {:vnode, tag, id, b_attrs, _, b_node_hash, children_hash}) when a_node_hash != b_node_hash do
    # Only attributes changed
    patch_attributes(ref(path, id), a_attrs, b_attrs)
  end

  def diff(
        path,
        {:vnode, tag, id, _, a_children, node_hash, a_children_hash},
        {:vnode, tag, id, _, b_children, node_hash, b_children_hash}) when a_children_hash != b_children_hash do
    # Only children changed
    patch_children(ref(path, id), a_children, b_children)
  end

  def diff(
        path,
        {:vnode, tag, id, a_attrs, a_children, a_node_hash, a_children_hash},
        {:vnode, tag, id, b_attrs, b_children, b_node_hash, b_children_hash}) do
    # Attributes and children changed
    patch_attributes(ref(path, id), a_attrs, b_attrs) ++
    patch_children(ref(path, id), a_children, b_children)
  end

  def diff(
        path,
        {:vnode, a_tag, a_id, a_attrs, a_children, a_node_hash, a_children_hash},
        {:vnode, b_tag, b_id, b_attrs, b_children, b_node_hash, b_children_hash}) do
    # Completely different tags
  end


  defp ref(path, id) do
    if id == :__no_id__ do
      path        # Full path list
    else
      [id, :id]   # Use shortcut direct to id.
    end
  end


  defp patch_attributes(path, a_attrs, b_attrs) do
    a_keys = keys(a_attrs) |> MapSet.new()
    b_keys = keys(b_attrs) |> MapSet.new()

    added_keys = MapSet.difference(b_keys, a_keys)
    removed_keys = MapSet.difference(a_keys, b_keys)
    same_keys = MapSet.intersection(a_keys, b_keys)

    map(
      removed_keys,
      fn key ->
        {:del_attr, path, key, :__no_val__}
      end) ++

    map(
      added_keys,
      fn key ->
        {:set_attr, path, key, b_attrs[key]}
      end) ++

    flat_map(
      same_keys,
      fn key ->
        case  a_attrs[key] == b_attrs[key] do
          true -> []
          false -> [{:set_attr, path, key, b_attrs[key]}]
        end
      end)

  end


  defp patch_children(path, a_children, b_children) do
    a_tag_id_index =
      a_children
      |> map(&tag_id_tree_hash/1)
      |> with_index
      |> group_by(
          fn {{tag_id, _}, _} ->
            tag_id
          end,
          fn {_, index} ->
            index
          end
        )
      |> MapSet.new

    b_tag_id_index =
      b_children
      |> map(&tag_id_tree_hash/1)
      |> with_index
      |> group_by(
          fn {{tag_id, _}, _} ->
            tag_id
          end,
          fn {_, index} ->
            index
          end
        )
      |> MapSet.new

    removed =
      MapSet.difference(a_tag_id_index, b_tag_id_index)
      |> MapSet.to_list
      |> map(
        fn {tag_id, indicies} ->
          {tag_id, %{removed: indicies}}
        end)

    added =
      MapSet.difference(b_tag_id_index, a_tag_id_index)
      |> MapSet.to_list
      |> map(
        fn {tag_id, indicies} ->
          {tag_id, %{added: indicies}}
        end)

    same =
      MapSet.intersection(a_tag_id_index, b_tag_id_index)
      |> MapSet.to_list
      |> map(
        fn {tag_id, indicies} ->
          {tag_id, %{same: indicies}}
        end)

    tag_id_ops =
      removed ++ added ++ same
      |> group_by(
          fn {tag_id, _} ->
            tag_id
          end,
          fn {_, index} ->
            index
          end
         )
      |> map(
          fn {tag_id, ops_list} ->
            {
              tag_id,
              reduce(
                ops_list,
                %{},
                &(merge(&1, &2))
              )
            }
          end
        )

    IO.inspect(tag_id_ops)
  end





end
