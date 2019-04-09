extern console

func foo(x) {
	for let value in x.foo while value ?= value.bar() {
		console.log(value)
	}
}