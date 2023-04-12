class Foobar {
	foobar(x) => 1
}

class Quxbaz extends Foobar {
	foobar(x) => 2
	foobar(x = 0, y = 0) => 3
}

func foobar(f: Foobar) => f.foobar('foobar')

var q = Quxbaz.new()

q.foobar('foobar')

foobar(q)

q.foobar(42)