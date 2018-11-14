extern console

func foo(x) {
	console.log(x)
}

func bar(x?) {
	console.log(x)
}

func baz(x = null) {
	console.log(x)
}

func qux(x = 'foobar') {
	console.log(x)
}

func quux(x: String) {
	console.log(x)
}

func corge(x: String?) {
	console.log(x)
}

func grault(x: String = null) {
	console.log(x)
}

func garply(x: String = 'foobar') {
	console.log(x)
}

func waldo(x: String? = null) {
	console.log(x)
}

func fred(x: String? = 'foobar') {
	console.log(x)
}