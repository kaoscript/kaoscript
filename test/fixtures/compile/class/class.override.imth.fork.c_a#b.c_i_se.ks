class Foobar {
	foobar(x) => x * 1
}

class Quxbaz extends Foobar {
	foobar(x: Number) => x * 2
	foobar(x: String) => x
}

func foobar(f: Foobar) => f.foobar('foobar')

var q = Quxbaz.new()

q.foobar('foobar')

foobar(q)

q.foobar(42)