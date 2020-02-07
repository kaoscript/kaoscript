require expect: func

extern sealed class Date

impl Date {
	private {
		const @culture	= 'und'
	}
	culture() => @culture
	culture(@culture) => this
}

const d = new Date()

expect(d.culture()).to.equal('und')

expect(d.culture('en')).to.equal(d)

expect(d.culture()).to.equal('en')

export Date