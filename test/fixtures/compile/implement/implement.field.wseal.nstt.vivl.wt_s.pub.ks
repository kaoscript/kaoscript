require expect: func

extern sealed class Date

impl Date {
	final late @culture: String
}

var d = Date.new()

expect(d.culture).to.not.exist

export Date