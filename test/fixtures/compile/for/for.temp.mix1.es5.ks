#![target(ecma-v5)]

extern console

func foo(x, y, z) {
	for value in y {
		console.log(value)
	}

	for value in z {
		console.log(value)
	}

	if x.bar? {
		for key, value of x.bar {
			console.log(key, value)
		}

		for key, value of x.bar {
			console.log(key, value)
		}
	}
}