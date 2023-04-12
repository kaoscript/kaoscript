require|import './require.alt.roi.loop3.genesis'

type NS = Number | String

disclose Date {
	internal {
		constructor(year: NS, month: NS, day: NS = 1, hours: NS = 0, minutes: NS = 0, seconds: NS = 0, milliseconds: NS = 0)
		getTimezoneOffset(): Number
		getUTCMinutes(): Number
		setUTCMinutes(minutes: Number = -1, seconds: Number = -1, ms: Number = -1): Number
	}
}

impl Date {
	overwrite constructor(year: NS, month: NS, day: NS = 1, hours: NS = 0, minutes: NS = 0, seconds: NS = 0, milliseconds: NS = 0) { # {{{
		precursor(year, month - 1, day, hours, minutes, seconds, milliseconds)

		this.setUTCMinutes(this.getUTCMinutes() - this.getTimezoneOffset())
	} # }}}
	fromAugment() {
	}
}

var d = Date.new(2000, 1, 20, 3, 45, 6, 789)

export Date