abstract class Foobar {
	abstract foobar(target: String? = null)
}
class Quxbaz extends Foobar {
	override foobar(target ??= '') {
	}
}

func foobar(f: Foobar) => f.foobar()

var q = new Quxbaz()

q.foobar()

foobar(q)