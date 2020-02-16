impl Date {
	foobar() {
	}
}

class FDate extends Date {
	constructor() {
		super()

		this.foobar()
	}
}

const d = new Date()
const f = new FDate()
const x: Date = (() => new FDate())()

d.foobar()
f.foobar()
x.foobar()