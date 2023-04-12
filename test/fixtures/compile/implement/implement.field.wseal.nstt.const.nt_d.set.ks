require expect: func

extern sealed class Date

impl Date {
	private {
		final @culture	= 'und'
	}
	culture() => @culture
	culture(@culture) => this
}

var d = Date.new()

expect(d.culture()).to.equal('und')

expect(d.culture('en')).to.equal(d)

expect(d.culture()).to.equal('en')

export Date