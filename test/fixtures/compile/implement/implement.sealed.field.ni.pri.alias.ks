require expect: func

extern sealed class Date

impl Date {
	private {
		@culture: String
	}
	culture() => @culture
	culture(@culture) => this
}

const d = new Date()

expect(d.culture()).to.not.exist

expect(d.culture('en')).to.equal(d)

expect(d.culture()).to.equal('en')

export Date