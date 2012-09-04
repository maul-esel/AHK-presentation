class Part
{
	__New(node)
	{
		this.node := node
		this.is_steps := node.getAttribute("steps") = "true"
		this.name := node.getAttribute("name")
		this.localized_name := Translator.getString(this.name)

		nodes := node.selectNodes("./part")
		Loop % nodes.length
			this.children.Insert(new Presentation.Part(nodes.item(A_Index - 1)))
	}

	created := false

	controls := []

	step := 0

	node := ""

	is_steps := false

	name := ""

	localized_name := ""

	children := []
}