abstract class Foobar {
	abstract foobar(x)
}

class Quxbaz extends Foobar {
	override foobar(x) => x * 1
	foobar(x: String) => x
}

func foobar(f: Foobar) => f.foobar('foobar')

var q = new Quxbaz()

q.foobar('foobar')

foobar(q)