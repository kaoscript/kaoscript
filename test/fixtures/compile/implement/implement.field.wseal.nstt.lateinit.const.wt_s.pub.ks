require expect: func

extern sealed class Date

impl Date {
	final late @culture: String
}

var d = new Date()

expect(d.culture).to.not.exist

export Date