class Foobar {
	foobar(x) => x * 1
}

class Quxbaz extends Foobar {
	foobar(x) => x * 2
}

func foobar(f: Foobar) => f.foobar('foobar')

const q = new Quxbaz()

q.foobar('foobar')

foobar(q)