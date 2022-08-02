class Foobar {
	foobar(x: Number) => 1
}

class Quxbaz extends Foobar {
	foobar(x: Number): Number => 2
}

var q = new Quxbaz()
var f = q.foobar(42)