class Foobar {
	foobar(x) => x * 1
}

class Quxbaz extends Foobar {
	foobar(x: String) => x
}

func foobar(f: Foobar) => f.foobar('foobar')

const q = new Quxbaz()

q.foobar('foobar')

foobar(q)

q.foobar(42)