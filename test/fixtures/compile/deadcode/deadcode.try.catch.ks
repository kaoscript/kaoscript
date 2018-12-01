extern console

func foo() {
	try {
		console.log('hello')
	}
	catch {
		return null
	}

	return 42
}