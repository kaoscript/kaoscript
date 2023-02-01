extern foo, bar, qux

var x = if foo() {
	if foo(2) {
		pick bar()
	}
	else if foo(5) {
		pick bar()
	}
}
else {
	pick qux()
}