abstract class Foobar {
	abstract foobar(x)
}

class Quxbaz extends Foobar {
	foobar(x: String) => x
}

func foobar(f: Foobar) => f.foobar('foobar')

const q = new Quxbaz()

q.foobar('foobar')

foobar(q)