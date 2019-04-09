extern console

func foo(x) {
	for const value in x.foo while value ?= value.bar() {
		console.log(value)
	}
}