extern foo, bar, qux

var x = if foo() {
	match foo(2) {
		1 {
			pick foo()
		}
		2..5 {
			pick foo(5)
		}
	}
}
else {
	pick qux()
}