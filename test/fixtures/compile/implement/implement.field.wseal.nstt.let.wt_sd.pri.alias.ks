require expect: func

extern sealed class Date

impl Date {
	private {
		@culture: String = 'und'
	}
	culture() => @culture
	culture(@culture) => this
}

var d = new Date()

expect(d.culture()).to.equal('und')

expect(d.culture('en')).to.equal(d)

expect(d.culture()).to.equal('en')

export Date