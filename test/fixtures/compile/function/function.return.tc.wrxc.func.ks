class Foobar {
}

class Quxbaz extends Foobar {
}

func foobar(test: Boolean): Foobar {
	if test {
		return new Quxbaz()
	}
	else {
		return new Foobar()
	}
}