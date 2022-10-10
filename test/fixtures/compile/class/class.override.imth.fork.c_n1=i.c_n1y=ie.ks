class Foobar {
	foobar(x: Number) {
		return 1
	}
}

class Quxbaz extends Foobar {
	foobar(x % _: Number) {
		return 2
	}
}