#![target(ecma-v5)]

extern console

func foo(x) {
	for value in x.foo when value ?= value.bar() {
		console.log(value)
	}
}