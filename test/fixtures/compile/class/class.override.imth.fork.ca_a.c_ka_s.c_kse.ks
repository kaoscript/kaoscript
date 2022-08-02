abstract class Foobar {
	abstract foobar(x)
}

class Quxbaz extends Foobar {
	override foobar(x) => x * 1
	foobar(x: String) => x
}

class Waldo extends Quxbaz {
	override foobar(x: String) => 'waldo'
}

func foobar(f: Foobar) => f.foobar('foobar')

var w = new Waldo()

w.foobar('foobar')

foobar(w)