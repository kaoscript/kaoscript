extern foo, bar, qux

var x = if foo() {
	set qux()
}
else {
	set bar()
}