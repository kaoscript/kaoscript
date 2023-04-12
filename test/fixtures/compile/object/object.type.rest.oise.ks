class Foobar {
	public args: Number{}	= {}
}

func clone(source: Foobar): Foobar {
	var clone = Foobar.new()

	clone.args = {...source.args}

	return clone
}