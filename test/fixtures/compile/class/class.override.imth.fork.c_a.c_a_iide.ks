class Foobar {
	foobar(x) => x
}

class Quxbaz extends Foobar {
	foobar(x) => x * 1
	foobar(x: Number, y: Number = 0) => y
}