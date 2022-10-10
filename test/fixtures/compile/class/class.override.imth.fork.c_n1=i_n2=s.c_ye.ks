class Foobar {
	foobar(x: Number) {
		return 1
	}
	foobar(y: String) {
		return 2
	}
}

class Quxbaz extends Foobar {
	foobar(_) {
		return 3
	}
}