class Foobar {
	public args: Dictionary<Number>	= {}
}

func clone(source: Foobar): Foobar {
	var clone = new Foobar()

	clone.args = {...source.args}

	return clone
}