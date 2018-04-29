defmodule VirtualDOM.VNode do
  @moduledoc false


  import Keyword, only: [keyword?: 1]
  import Macro, only: [postwalk: 2]


  @tags [
      :a, :abbr, :acronym, :address, :applet, :area, :article, :aside, :audio,
      :b, :base, :basefont, :bdo, :big, :blockquote, :body, :br, :button,
      :canvas, :caption, :center, :cite, :code, :col, :colgroup,
      :datalist, :dd, :del, :dfn, :div, :dl, :dt,
      :em, :embed, :fieldset, :figcaption, :figure, :font, :footer, :form, :frame, :frameset,
      :head, :header, :h1, :h2, :h3, :h4, :h5, :h6, :hr, :html,
      :i, :iframe, :img, :input, :ins, :kbd,
      :label, :legend, :li, :link,
      :main, :map, :mark, :meta, :meter,
      :nav, :noscript,
      :object, :ol, :optgroup, :option,
      :p, :param, :pre, :progress,
      :q,
      :s, :samp, :script, :section, :select, :small, :source, :span, :strike, :strong, :style, :sub, :sup,
      :table, :tbody, :text, :td, :textarea, :tfoot, :th, :thead, :time, :title, :tr,
      :u, :ul,
      :var, :video,
      :wbr]


  defmacro view(do: block) do
    #Macro.postwalk(block, fn seg -> IO.inspect(seg) end)

    quote do
      import Kernel, except: [div: 2]
      unquote(postwalk(block, &postwalk/1))
    end

  end

  # TODO  keep line numbers for error messages

  defp postwalk({tag, _, nil}) when tag in @tags do
    quote do
      vnode(to_string(unquote(tag)), :noid)
    end
  end

  defp postwalk({tag, _, [id]}) when tag in @tags
      and is_bitstring(id) do
    quote do
      vnode(to_string(unquote(tag)), unquote(id))
    end
  end

  defp postwalk({tag, _, [[do: {:__block__, _, children}]]}) when tag in @tags
      and is_list(children) do
    quote do
      vnode(to_string(unquote(tag)), :noid, [], unquote(children))
    end
  end

  defp postwalk({tag, _, [[do: child]]}) when tag in @tags do
    quote do
      vnode(to_string(unquote(tag)), :noid, [], [unquote(child)])
    end
  end


  defp postwalk({tag, _, [attrs]}) when tag in @tags
    and is_list(attrs) do

    quote do
      vnode(to_string(unquote(tag)), :noid, unquote(attrs), [])
    end
  end

  defp postwalk({tag, _, [attrs, [do: children]]}) when tag in @tags
    and is_list(attrs)
    and is_list(children) do

    quote do
      vnode(to_string(unquote(tag)), :noid, unquote(attrs), unquote(children))
    end
  end

  defp postwalk({tag, _, [attrs, [do: child]]}) when tag in @tags
    and is_list(attrs) do

    quote do
      vnode(to_string(unquote(tag)), :noid, unquote(attrs), [unquote(child)])
    end
  end

  defp postwalk(ast) do
    ast
  end


  def vnode(tag) when is_bitstring(tag) do

    vnode(tag, :noid, [], [])

  end

  def vnode(tag, id) when is_bitstring(tag)
      and (is_bitstring(id) or id == :noid) do

    vnode(tag, id, [], [])

  end

  def vnode(tag, attributes_or_children) when is_bitstring(tag)
      and is_list(attributes_or_children) do

    vnode(tag, :noid, attributes_or_children)

  end

  def vnode(tag, id, attributes_or_children) when is_bitstring(tag)
      and (is_bitstring(id) or id == :noid)
      and is_list(attributes_or_children) do

    cond do
      keyword?(attributes_or_children) ->
        {:vnode, tag, :noid, attributes_or_children, []}

      vnode_list?(attributes_or_children) ->
        {:vnode, tag, :noid, [], attributes_or_children}

      true ->
        raise """
        List following vnode #{tag} must be either
        attribute keyword list or child vnode list
        """

    end

  end

  def vnode(tag, id, attributes, children) when is_bitstring(tag)
        and (is_bitstring(id) or id == :noid)
        and is_list(attributes)
        and is_list(children) do

    cond do
      not keyword?(attributes) ->
        raise "Attributes of vnode #{tag} must be a keyword list"

      not vnode_list?(children) ->
        raise "Children of vnode #{tag} must all be vnodes"

      true ->
        {:vnode, tag, id, attributes, children}

    end

  end



  def vnode?({:vnode, tag, id, attributes, children}) when is_bitstring(tag)
        and (is_bitstring(id) or id == :noid)
        and is_list(attributes)
        and is_list(children) do

        keyword?(attributes) and vnode_list?(children)

  end

  def vnode?(_) do
    false
  end


  def vnode_list?([]) do
    true
  end

  def vnode_list?([head | tail]) do
    vnode?(head) and vnode_list?(tail)
  end

end
