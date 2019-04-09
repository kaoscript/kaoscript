extern console

func foo(x) {
	for key, value of x.foo while value ?= value.bar() {
		console.log(key, value)
	}
}