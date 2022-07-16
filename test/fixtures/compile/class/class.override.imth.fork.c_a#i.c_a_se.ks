class Foobar {
	foobar(x): Number => 0
}

class Quxbaz extends Foobar {
	foobar(x) => 1
	foobar(x: String) => 2
}