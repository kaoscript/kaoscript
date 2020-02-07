require expect: func

extern sealed class Date

impl Date {
	lateinit const @culture: String
}

const d = new Date()

expect(d.culture).to.not.exist

export Date