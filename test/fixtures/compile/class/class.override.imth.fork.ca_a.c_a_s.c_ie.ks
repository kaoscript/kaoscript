abstract class Foobar {
	abstract foobar(x)
}

class Quxbaz extends Foobar {
	foobar(x) => x * 1
	foobar(x: String) => x
}

class Waldo extends Quxbaz {
	foobar(x: Number) => x * 10
}

func foobar(f: Foobar) => f.foobar(42)

const w = new Waldo()

w.foobar(42)

foobar(w)