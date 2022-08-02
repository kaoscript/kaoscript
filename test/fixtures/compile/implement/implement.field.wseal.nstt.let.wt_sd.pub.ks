require expect: func

extern sealed class Date

impl Date {
	@culture: String = 'und'
}

var d = new Date()

expect(d.culture).to.equal('und')

d.culture = 'en'

expect(d.culture).to.equal('en')

var culture = d.culture

export Date