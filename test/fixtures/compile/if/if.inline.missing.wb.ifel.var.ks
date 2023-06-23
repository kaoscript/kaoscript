extern foo, bar, qux

var x = if foo() {
	if foo(2) {
		set bar()
	}
	else if foo(5) {
		set bar()
	}
}
else {
	set qux()
}