class Foobar {
	public values: Number{}	= {}
}

func set(name: String, value: String): Foobar {
	var clone = new Foobar()

	clone.values = {
		[name]: value
	}

	return clone
}