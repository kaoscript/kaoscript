require expect: func

extern sealed class Date
extern console

impl Date {
	private {
		@culture: String = 'und'
	}
	culture() => @culture
	culture(@culture) => this
}

expect(new Date().culture()).to.equal('und')

var d = new Date()

expect(d.culture('en')).to.equal(d)

expect(d.culture()).to.equal('en')