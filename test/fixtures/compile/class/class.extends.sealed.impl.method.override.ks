impl Date {
	foobar() {
	}
}

class FDate extends Date {
	override foobar() {
		super()
	}
}

const d = new Date()
const f = new FDate()
const x: Date = (() => new FDate())()

d.foobar()
f.foobar()
x.foobar()