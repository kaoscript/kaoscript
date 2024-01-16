extern foo, bar, qux

var x = if foo() {
	match foo(2) {
		1 {
			set foo()
		}
		2..5 {
			set foo(5)
		}
	}
}
else {
	set qux()
}