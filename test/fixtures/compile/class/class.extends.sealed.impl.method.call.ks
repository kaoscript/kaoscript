impl Date {
	foobar() {
	}
}

class FDate extends Date {
}

var d = new Date()
var f = new FDate()

d.foobar()
f.foobar()
