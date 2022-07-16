class Foobar {
	foobar(...a) {
		return 0
	}
}

class Quxbaz extends Foobar {
	foobar(a: Number) {
		return 1
	}
	foobar(a: Number, b: Number) {
		return 2
	}
}