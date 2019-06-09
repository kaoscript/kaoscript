extern console

func foo(x) {
	if x.foo? {
		for value, key of x.foo {
			console.log(key, value)
		}
	}

	if x.bar? {
		for value, key of x.bar {
			console.log(key, value)
		}
	}
}