abstract class Foobar {
	abstract foobar(x)
}

class Quxbaz extends Foobar {
	foobar(x) => x * 1
	foobar(x: String) => x
}

func foobar(f: Foobar) => f.foobar('foobar')

var q = Quxbaz.new()

q.foobar('foobar')

foobar(q)

q.foobar(42)