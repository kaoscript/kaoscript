extern console

func foo(x) {
	for value, key of x.foo {
		console.log(key, value)
	}

	for value, key of x.bar {
		console.log(key, value)
	}
}