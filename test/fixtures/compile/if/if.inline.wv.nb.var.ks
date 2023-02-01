extern foo, bar, qux

var x = if var y ?= foo() {
	pick qux(y)
}
else {
	pick bar()
}