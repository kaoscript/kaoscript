require expect: func

extern sealed class Date

impl Date {
	const @culture	= 'und'
}

const d = new Date()

expect(d.culture).to.not.exist

export Date