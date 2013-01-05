class Viewbox
{
	Width := 100
	Height := 100

	__New(w, h)
	{
		if (w)
			this.Width := w
		if (h)
			this.Height := h
	}

	FromNode(node, recurse = true)
	{
		box := node.selectSingleNode("viewbox")
		if (box)
			return new Viewbox(box.getAttribute("width"), box.getAttribute("height"))
		else if (node.parentNode && recurse)
			return Viewbox.FromNode(node.parentNode)
	}
}