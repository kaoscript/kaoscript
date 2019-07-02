class Foobar {
	toString(): String => 'foobar'
}

func foobar(x: String): Foobar {
	return new Foobar()
}

export foobar