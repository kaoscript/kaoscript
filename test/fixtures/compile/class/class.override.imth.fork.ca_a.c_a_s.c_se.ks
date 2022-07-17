abstract class Foobar {
	abstract foobar(x)
}

class Quxbaz extends Foobar {
	foobar(x) => x * 1
	foobar(x: String) => x
}

class Waldo extends Quxbaz {
	foobar(x: String) => 'waldo'
}

func foobar(f: Foobar) => f.foobar('foobar')

const w = new Waldo()

w.foobar('foobar')

foobar(w)