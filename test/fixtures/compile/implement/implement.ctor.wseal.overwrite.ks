extern sealed class Foobar

disclose Foobar {
	constructor(x: Number)
}

impl Foobar {
	overwrite constructor(x: Number) {
		this.foobar()
	}
	foobar() {
	}
}