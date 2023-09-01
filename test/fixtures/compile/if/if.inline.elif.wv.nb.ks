extern foo, bar

var x = if foo() {
	set 0
}
else if var y ?= bar() {
	set y
}
else {
	set 2
}