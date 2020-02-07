require expect: func

extern sealed class Date

impl Date {
	lateinit @culture: String
}

const d = new Date()

expect(d.culture).to.not.exist

d.culture = 'en'

expect(d.culture).to.equal('en')

const culture = d.culture

export Date