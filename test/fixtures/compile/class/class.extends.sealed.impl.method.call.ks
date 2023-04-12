impl Date {
	foobar() {
	}
}

class FDate extends Date {
}

var d = Date.new()
var f = FDate.new()

d.foobar()
f.foobar()
