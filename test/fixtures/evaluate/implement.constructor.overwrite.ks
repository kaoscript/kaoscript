require expect: func

extern sealed class Date

#[rules(non-exhaustive)]
disclose Date {
	internal {
		constructor(year, month, day = 1, hours = 0, minutes = 0, seconds = 0, milliseconds = 0)
	}
}

impl Date {
	overwrite constructor(year, month, day = 1, hours = 0, minutes = 0, seconds = 0, milliseconds = 0) {
		precursor(year, month - 1, day, hours, minutes, seconds, milliseconds)

		this.setUTCMinutes(this.getUTCMinutes() - this.getTimezoneOffset())
	}
}

var d = Date.new(2000, 1, 1)
expect(d.getUTCFullYear()).to.equals(2000)
expect(d.getUTCMonth()).to.equals(0)
expect(d.getUTCDate()).to.equals(1)