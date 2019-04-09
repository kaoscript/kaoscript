extern console

func foo(x) {
	for key, value of x.foo when value ?= value.bar() {
		console.log(key, value)
	}
}