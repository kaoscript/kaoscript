extern foo, bar, qux

var x = if var y ?= foo() {
	set qux(y)
}
else {
	set bar()
}