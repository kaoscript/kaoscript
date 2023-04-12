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

expect(Date.new().culture()).to.equal('und')

var d = Date.new()

expect(d.culture('en')).to.equal(d)

expect(d.culture()).to.equal('en')