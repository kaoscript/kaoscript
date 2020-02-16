impl Date {
	foobar() {
	}
}

class FDate extends Date {
}

const d = new Date()
const f = new FDate()

d.foobar()
f.foobar()
