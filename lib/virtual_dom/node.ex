defmodule VirtualDOM.VNode do
  @moduledoc false


  import Keyword, only: [keyword?: 1]
  import Macro, only: [postwalk: 2]
  import XXHash, only: [xxh32: 1]
  import Enum, only: [into: 2, map: 2]


  # From https://npm.runkit.com/svg-tag-names
  # x = [...new Set(svgTagNames.concat(htmlTagNames))].sort().join(", :")
  # - -> _
  # Could add compile-time attribute checking later
  @tags [
    :a, :abbr, :acronym, :address, :altGlyph, :altGlyphDef, :altGlyphItem,
    :animate, :animateColor, :animateMotion, :animateTransform, :animation,
    :applet, :area, :article, :aside, :audio, :b, :base, :basefont, :bdi,
    :bdo, :bgsound, :big, :blink, :blockquote, :body, :br, :button, :canvas,
    :caption, :center, :circle, :cite, :clipPath, :code, :col, :colgroup,
    :color_profile, :command, :content, :cursor, :data, :datalist, :dd,
    :defs, :del, :desc, :details, :dfn, :dialog, :dir, :discard, :div, :dl,
    :dt, :element, :ellipse, :em, :embed, :feBlend, :feColorMatrix,
    :feComponentTransfer, :feComposite, :feConvolveMatrix, :feDiffuseLighting,
    :feDisplacementMap, :feDistantLight, :feDropShadow, :feFlood, :feFuncA,
    :feFuncB, :feFuncG, :feFuncR, :feGaussianBlur, :feImage, :feMerge,
    :feMergeNode, :feMorphology, :feOffset, :fePointLight, :feSpecularLighting,
    :feSpotLight, :feTile, :feTurbulence, :fieldset, :figcaption, :figure,
    :filter, :font, :font_face, :font_face_format, :font_face_name,
    :font_face_src, :font_face_uri, :footer, :foreignObject, :form, :frame,
    :frameset, :g, :glyph, :glyphRef, :h1, :h2, :h3, :h4, :h5, :h6, :handler,
    :hatch, :hatchpath, :head, :header, :hgroup, :hkern, :hr, :html, :i,
    :iframe, :image, :img, :input, :ins, :isindex, :kbd, :keygen, :label,
    :legend, :li, :line, :linearGradient, :link, :listener, :listing, :main,
    :map, :mark, :marker, :marquee, :mask, :math, :menu, :menuitem, :mesh,
    :meshgradient, :meshpatch, :meshrow, :meta, :metadata, :meter, :missing_glyph,
    :mpath, :multicol, :nav, :nextid, :nobr, :noembed, :noframes, :noscript,
    :object, :ol, :optgroup, :option, :output, :p, :param, :path, :pattern,
    :picture, :plaintext, :polygon, :polyline, :pre, :prefetch, :progress,
    :q, :radialGradient, :rb, :rbc, :rect, :rp, :rt, :rtc, :ruby, :s, :samp,
    :script, :section, :select, :set, :shadow, :slot, :small, :solidColor,
    :solidcolor, :source, :spacer, :span, :stop, :strike, :strong, :style,
    :sub, :summary, :sup, :svg, :switch, :symbol, :table, :tbody, :tbreak,
    :td, :template, :text, :textArea, :textPath, :textarea, :tfoot, :th,
    :thead, :time, :title, :tr, :track, :tref, :tspan, :tt, :u, :ul, :unknown,
    :use, :var, :video, :view, :vkern, :wbr, :xmp]

  defmacro view(do: block) do
    quote do
      import Kernel, except: [div: 2]
      unquote(postwalk(block, &postwalk/1))
    end

  end


  defp postwalk({tag, _, nil}) when tag in @tags do
    quote do
      vnode(to_string(unquote(tag)), :__no_id__)
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
      vnode(to_string(unquote(tag)), :__no_id__, [], unquote(children))
    end
  end

  defp postwalk({tag, _, [[do: child]]}) when tag in @tags do
    quote do
      vnode(to_string(unquote(tag)), :__no_id__, [], [unquote(child)])
    end
  end


  defp postwalk({tag, _, [attrs]}) when tag in @tags
    and is_list(attrs) do

    quote do
      vnode(to_string(unquote(tag)), :__no_id__, unquote(attrs), [])
    end
  end

  defp postwalk({tag, _, [attrs, [do: children]]}) when tag in @tags
    and is_list(attrs)
    and is_list(children) do

    quote do
      vnode(to_string(unquote(tag)), :__no_id__, unquote(attrs), unquote(children))
    end
  end

  defp postwalk({tag, _, [attrs, [do: child]]}) when tag in @tags
    and is_list(attrs) do

    quote do
      vnode(to_string(unquote(tag)), :__no_id__, unquote(attrs), [unquote(child)])
    end
  end

  defp postwalk(ast) do
    ast
  end


  def vnode(tag) when is_bitstring(tag) do

    vnode(tag, :__no_id__, [], [])

  end

  def vnode(tag, id) when is_bitstring(tag)
      and (is_bitstring(id) or id == :__no_id__) do

    vnode(tag, id, [], [])

  end

  def vnode(tag, attributes_or_children) when is_bitstring(tag)
      and is_list(attributes_or_children) do

    vnode(tag, :__no_id__, attributes_or_children)

  end

  def vnode(tag, id, attributes_or_children) when is_bitstring(tag)
      and (is_bitstring(id) or id == :__no_id__)
      and is_list(attributes_or_children) do

    cond do
      keyword?(attributes_or_children) ->
        vnode(tag, :__no_id__, attributes_or_children, [])

      vnode_list?(attributes_or_children) ->
        vnode(tag, :__no_id__, [], attributes_or_children)

      true ->
        raise """
        List following vnode #{tag} must be either
        attribute keyword list or child vnode list
        """

    end

  end

  def vnode(tag, attributes, children) when is_bitstring(tag)
        and is_list(attributes)
        and is_list(children) do

    vnode(tag, :__no_id__, attributes, children)

  end

  def vnode(tag, id, attributes, children) when is_bitstring(tag)
        and (is_bitstring(id) or id == :__no_id__)
        and is_list(attributes)
        and is_list(children) do

    cond do
      not keyword?(attributes) ->
        raise "Attributes of vnode #{tag} must be a keyword list"

      not vnode_list?(children) ->
        raise "Children of vnode #{tag} must all be vnodes"

      true ->
        node_hash = inspect({tag,id,attributes})
        children_hash = inspect(children |> map(&tree_hash/1))
        {
          :vnode,
          tag,
          id,
          into(attributes, %{}),
          children,
          xxh32(node_hash),
          xxh32(children_hash)
        }

    end

  end


  def vnode?({:vnode, tag, id, attributes, children, node_hash, tree_hash}) when is_bitstring(tag)
        and (is_bitstring(id) or id == :__no_id__)
        and is_map(attributes)
        and is_list(children)
        and is_integer(node_hash)
        and is_integer(tree_hash) do

        is_map(attributes) and vnode_list?(children)

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


  def tree_hash({:vnode, _, _, _, _, node_hash, children_hash}) do
    node_hash * 10000000000 + children_hash
  end


  def tag_id_tree_hash({:vnode, tag, :__no_id__, _, _, node_hash, children_hash}) do
    tree_hash = node_hash * 10000000000 + children_hash
    {{tag, tree_hash}, tree_hash}
  end

  def tag_id_tree_hash({:vnode, tag, id, _, _, node_hash, children_hash}) do
    {{tag, id}, node_hash * 10000000000 + children_hash}
  end

end
