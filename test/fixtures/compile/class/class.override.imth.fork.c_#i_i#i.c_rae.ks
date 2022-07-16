class Quxbaz {
	foobar(): Number => 1
	foobar(x: Number): Number => 2
}

class Waldo extends Quxbaz {
	foobar(...args) => 3
}