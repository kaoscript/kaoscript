extern sealed class Date

disclose Date {
	constructor()
	constructor(Date: date)

	internal {
		constructor(year, month, day = 1, hours = 0, minutes = 0, seconds = 0, milliseconds = 0)
		getTimezoneOffset(): Number
		getUTCMinutes(): Number
		setUTCMinutes(minutes: Number = -1, seconds: Number = -1, ms: Number = -1): Number
	}
}

impl Date {
	overwrite constructor(year, month, day = 1, hours = 0, minutes = 0, seconds = 0, milliseconds = 0) {
		precursor(year, month - 1, day, hours, minutes, seconds, milliseconds)

		this.setUTCMinutes(this.getUTCMinutes() - this.getTimezoneOffset())
	}
}

var d1 = Date.new()
var d2 = Date.new(d1)
var d3 = Date.new(2000, 1, 1)

export Date