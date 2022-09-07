extern system class Date

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
	constructor(year, month, day = 0, hours = 0, minutes = 0, seconds = 0, milliseconds = 0, timezone) {
		this(year, month, day, hours, minutes, seconds, milliseconds)

		if timezone is String {
			@timezone = timezone
		}
	}
}

var d = new Date(2015, 6, 15, 9, 3, 1, 550, 'Europe/Paris')

export Date