class Foobar {
	public values: Dictionary<Number>	= {}
}

func set(name: String, value: Number): Foobar {
	var clone = new Foobar()

	clone.values = {
		[name]: value
	}

	return clone
}