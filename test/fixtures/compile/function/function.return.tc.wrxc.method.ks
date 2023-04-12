class Foobar {
	foobar(test: Boolean): Foobar {
		if test {
			return Quxbaz.new()
		}
		else {
			return Foobar.new()
		}
	}
}

class Quxbaz extends Foobar {
}