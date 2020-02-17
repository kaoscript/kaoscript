impl Date {
	foobar(): Number => 0
}

class FDate extends Date {
	constructor() {
		super()

		super.foobar()
	}
}