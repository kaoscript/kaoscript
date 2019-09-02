class Foobar {
	static create(): Foobar {
		return new Foobar()
	}
	foobar(): Foobar? => this
	quxbaz(): Boolean => true
}

if (x ?= Foobar.create().foobar()) && x.quxbaz() {
}