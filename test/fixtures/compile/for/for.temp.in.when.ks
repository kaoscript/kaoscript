extern console

func foo(x) {
	var dyn value

	for value in x.foo when value ?= value.bar() {
		console.log(value)
	}
}