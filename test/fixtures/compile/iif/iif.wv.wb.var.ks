extern foo, bar, qux

var x = if var mut y ?= foo() {
	for var i from 1 to 10 {
		y += bar(i)!?
	}

	set y
}
else {
	set bar()
}