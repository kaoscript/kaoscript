class Foobar {
	foobar(x: Number) => 1
}

class Quxbaz extends Foobar {
	foobar(x: Number): Number => 2
}

const q = new Quxbaz()
const f = q.foobar(42)