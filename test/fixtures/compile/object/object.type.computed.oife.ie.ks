class Foobar {
	public values: Object<Number>	= {}
}

func set(name: String, value: Number): Foobar {
	var clone = Foobar.new()

	clone.values = {
		[name]: value
	}

	return clone
}