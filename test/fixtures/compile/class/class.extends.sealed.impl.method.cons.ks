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

var d = Date.new()
var f = FDate.new()
var x: Date = (() => FDate.new())()

d.foobar()
f.foobar()
x.foobar()