class Foobar {
	public args: Number{}	= {}
}

func clone(source: Foobar): Foobar {
	var clone = new Foobar()

	clone.args = {...source.args}

	return clone
}