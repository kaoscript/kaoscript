class Foobar {
	static create(): Foobar {
		return Foobar.new()
	}
	foobar(): Foobar? => this
	quxbaz(): Boolean => true
}

var dyn x

if (x ?= Foobar.create().foobar()) && x.quxbaz() {
}