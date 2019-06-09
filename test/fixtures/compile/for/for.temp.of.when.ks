extern console

func foo(x) {
	for value, key of x.foo when value ?= value.bar() {
		console.log(key, value)
	}
}