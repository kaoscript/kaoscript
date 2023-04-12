class Foobar {
	public values: Number{}	= {}
}

func set(name: String, value: String): Foobar {
	var clone = Foobar.new()

	clone.values = {
		[name]: value
	}

	return clone
}