class Foobar {
	toString(): String => 'foobar'
}

func foobar(x: String): Foobar {
	return Foobar.new()
}

export foobar