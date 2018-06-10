defmodule VirtualDOM.Diff do
  @moduledoc false

  import Enum, only: [flat_map: 2]

  def diff(
        a = {:vnode, _, _, _, _, _, _},
        b = {:vnode, _, _, _, _, _, _}) do
    diff([], a, b) # Prepend empty path
    # TODO reverse path lists?
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
    [{:set_text, path, b_text}]  # Text is special case, we use id for text content
  end

  def diff(
        path,
        {:vnode, tag, id, a_attrs, _, a_node_hash, children_hash},
        {:vnode, tag, id, b_attrs, _, b_node_hash, children_hash}) when a_node_hash != b_node_hash do
    patch_attrs(ref(path, id), a_attrs, b_attrs)
  end


  defp ref(path, id) do
    if id == :noid do
      path        # Full path list
    else
      [id, :id]   # Use shortcut direct to id.
                  # Paths are in reverse order for append performance.
    end
  end


  defp patch_attrs(path, a_attrs, b_attrs) do
    a_keys = MapSet.new(Map.keys(a_attrs))
    b_keys = MapSet.new(Map.keys(b_attrs))

    added_keys = MapSet.difference(b_keys, a_keys)
    removed_keys = MapSet.difference(a_keys, b_keys)
    same_keys = MapSet.intersection(a_keys, b_keys)

    flat_map(
      removed_keys,
      fn key ->
        [{:del_attr, path, key}]
      end) ++

    flat_map(
      added_keys,
      fn key ->
        [{:set_attr, path, key, b_attrs[key]}]
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



end
