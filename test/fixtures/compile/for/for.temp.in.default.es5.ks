#![target(ecma-v5)]

extern console

func foo(x) {
	if x.foo? {
		for value in x.foo {
			console.log(value)
		}
	}

	if x.bar? {
		for value in x.bar {
			console.log(value)
		}
	}
}