extern console

func foo(x) {
	for value, key of x.foo while value ?= value.bar() {
		console.log(key, value)
	}
}