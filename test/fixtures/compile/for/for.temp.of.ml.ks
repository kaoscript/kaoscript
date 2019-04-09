extern console

func foo(x) {
	for key, value of x.foo {
		console.log(key, value)
	}

	for key, value of x.bar {
		console.log(key, value)
	}
}