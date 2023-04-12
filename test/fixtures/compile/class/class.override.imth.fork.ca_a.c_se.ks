abstract class Foobar {
	abstract foobar(x)
}

class Quxbaz extends Foobar {
	foobar(x: String) => x
}

func foobar(f: Foobar) => f.foobar('foobar')

var q = Quxbaz.new()

q.foobar('foobar')

foobar(q)