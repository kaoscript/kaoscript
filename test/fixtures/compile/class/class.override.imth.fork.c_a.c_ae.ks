class Foobar {
	foobar(x) => x * 1
}

class Quxbaz extends Foobar {
	foobar(x) => x * 2
}

func foobar(f: Foobar) => f.foobar('foobar')

var q = Quxbaz.new()

q.foobar('foobar')

foobar(q)