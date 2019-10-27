require expect: func

extern sealed class Date

disclose Date {
	getHours(): Number
	internal getUTCHours(): Number
	setHours(hours: Number, minutes: Number = -1, seconds: Number = -1, ms: Number = -1): Number
	internal setUTCHours(hours: Number, minutes: Number = -1, seconds: Number = -1, ms: Number = -1): Number
}

impl Date {
	overwrite getHours() => this.getUTCHours()
	overwrite setHours(hours: Number): Date {
		this.setUTCHours(hours)

		return this
	}
}

const d = new Date()

expect(d.setHours(12)).to.equal(d)
expect(d.getHours()).to.equal(12)

export Date