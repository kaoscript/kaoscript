extern console

func foo(x) {
	var dyn value, key

	for value, key of x.foo while value ?= value.bar() {
		console.log(key, value)
	}
}