class Foobar {
	public args: Number{}	= {}
}

func clone(source: Foobar): Foobar {
	var result = Foobar.new()

	result.args = {...source.args}

	return result
}