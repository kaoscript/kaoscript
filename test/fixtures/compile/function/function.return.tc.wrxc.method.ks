class Foobar {
	foobar(test: Boolean): Foobar {
		if test {
			return new Quxbaz()
		}
		else {
			return new Foobar()
		}
	}
}

class Quxbaz extends Foobar {
}