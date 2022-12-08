class Foobar {
	public values: Object<Number>	= {}
}

func set(name: String, value: Number): Foobar {
	var clone = new Foobar()

	clone.values = {
		[name]: value
	}

	return clone
}