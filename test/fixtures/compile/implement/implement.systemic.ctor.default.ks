extern systemic class Date

disclose Date {
	constructor()
	constructor(date: Date)
	constructor(time: Number)
	constructor(year, month, day = 0, hours = 0, minutes = 0, seconds = 0, milliseconds = 0)
}

impl Date {
	private {
		@timezone: String	= 'Etc/UTC'
	}
	overwrite constructor(year, month, day = 1, hours = 0, minutes = 0, seconds = 0, milliseconds = 0) {
		precursor(year, month - 1, day, hours, minutes, seconds, milliseconds)
	}
}

var d = new Date(2015, 6, 15, 9, 3, 1, 550)

export Date