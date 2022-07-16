require expect: func

class Foobar {
	foobar(x) => false
}

class Quxbaz extends Foobar {
	foobar(x: Number): Boolean => true
}

func foobar(f: Foobar) {
	expect(f.foobar(0)).to.equals(true)
}

foobar(new Quxbaz())