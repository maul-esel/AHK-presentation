class Part
{
	__New(node)
	{
		this.node := node
		this.is_steps := node.getAttribute("steps") = "true"
		this.name := node.getAttribute("name")
		this.localized_name := Translator.getString(this.name)

		this.children := new Presentation.PartCollection(this)
		nodes := node.selectNodes("./part")
		Loop % nodes.length
			this.children.Add(new Presentation.Part(nodes.item(A_Index - 1)))

		if (this.is_steps)
			this.steps := (s := node.selectSingleNode("./*/@step[not(. < ../preceding-sibling::*/@step) and not(. < ../following-sibling::*/@step)]").nodeValue) ? s : 0
	}

	Collection := ""

	created := false

	controls := []

	steps := 0

	step := 0

	node := ""

	is_steps := false

	name := ""

	localized_name := ""

	children := ""
}