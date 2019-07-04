#![target(ecma-v5)]

class Foobar {
}

class Quxbaz extends Foobar {
	foobar() {
		super.foobar()
	}
}