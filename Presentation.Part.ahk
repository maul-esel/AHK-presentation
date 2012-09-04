class Part
{
	__New(node)
	{
		this.node := node
		this.is_steps := node.getAttribute("steps") = "true"
		this.name := node.getAttribute("name")
	}

	created := false

	controls := []

	step := 0

	node := ""

	is_steps := false

	name := ""
}