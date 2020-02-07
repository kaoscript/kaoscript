require expect: func

extern sealed class Date

impl Date {
	private {
		lateinit const @culture: String
	}
	culture() => @culture
	culture(@culture) => this
}

const d = new Date()

expect(d.culture()).to.equal('und')

expect(d.culture('en')).to.equal(d)

expect(d.culture()).to.equal('en')

export Date