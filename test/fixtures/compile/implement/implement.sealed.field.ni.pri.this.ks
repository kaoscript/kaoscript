require expect: func

extern sealed class Date

impl Date {
	private {
		_culture: String
	}
	culture() => this._culture
	culture(culture: String) {
		this._culture = culture

		return this
	}
}

const d = new Date()

expect(d.culture()).to.not.exist

expect(d.culture('en')).to.equal(d)

expect(d.culture()).to.equal('en')