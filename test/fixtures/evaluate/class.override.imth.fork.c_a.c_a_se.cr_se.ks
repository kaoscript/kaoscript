require expect: func

abstract class Foobar {
	abstract foobar(value)
}

class Quxbaz extends Foobar {
	foobar(value) => 1
	foobar(value: String) => 2
}

func getFoobar(): Foobar => new Quxbaz()

const f = getFoobar()

expect(f.foobar('foobar')).to.equal(2)