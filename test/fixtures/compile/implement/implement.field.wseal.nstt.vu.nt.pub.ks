require expect: func

extern sealed class Date

impl Date {
	@culture
}

var d = Date.new()

expect(d.culture).to.not.exist

d.culture = 'en'

expect(d.culture).to.equal('en')

var culture = d.culture

export Date