require expect: func

extern sealed class Date

impl Date {
	final @culture	= 'und'
}

var d = new Date()

expect(d.culture).to.not.exist

export Date