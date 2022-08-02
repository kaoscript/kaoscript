require expect: func

extern sealed class Date

impl Date {
	private {
		_culture: String = 'und'
	}
	culture() => this._culture
	culture(culture: String) {
		this._culture = culture

		return this
	}
}

var d = new Date()

expect(d.culture()).to.equal('und')

expect(d.culture('en')).to.equal(d)

expect(d.culture()).to.equal('en')