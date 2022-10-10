class Foobar {
	foobar(x) => x
}

class Quxbaz extends Foobar {
	foobar(x) => x * 1
	foobar(y: String, z: Number = 0) => y
}