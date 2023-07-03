extern console

func foo(x) {
	var dyn value

	for value in x.foo while value ?= value.bar() {
		console.log(value)
	}
}