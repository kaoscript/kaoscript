extern console

func foo(x) {
	var dyn value, key

	for value, key of x.foo {
		console.log(key, value)
	}

	for value, key of x.bar {
		console.log(key, value)
	}
}