extern console

func foo(x) {
	for value in x.foo while value ?= value.bar() {
		console.log(value)
	}
}