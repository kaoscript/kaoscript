impl Date {
	foobar() {
	}
}

class FDate extends Date {
	foobar() {
		super.foobar()
	}
}

var d = new Date()
var f = new FDate()
var x: Date = (() => new FDate())()

d.foobar()
f.foobar()
x.foobar()