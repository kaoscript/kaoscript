extern console

func foo(x) {
	var dyn value

	for value in x.foo {
		console.log(value)
	}

	for value in x.bar {
		console.log(value)
	}
}