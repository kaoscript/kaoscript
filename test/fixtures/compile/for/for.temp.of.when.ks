extern console

func foo(x) {
	var dyn value, key

	for value, key of x.foo when value ?= value.bar() {
		console.log(key, value)
	}
}