extern console

func foo(x, y, z) {
	for value in y {
		console.log(value)
	}

	for value in z {
		console.log(value)
	}

	if x.bar? {
		for value, key of x.bar {
			console.log(key, value)
		}

		for value, key of x.bar {
			console.log(key, value)
		}
	}
}