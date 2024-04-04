impl Date {
	foobar() {
	}
}

class FDate extends Date {
	override foobar() {
		super()
	}
}

var d = Date.new()
var f = FDate.new()
var x = (() => FDate.new())():!!(Date)

d.foobar()
f.foobar()
x.foobar()