extern console

func foo() {
	try {
		return console.log('hello')
	}
	catch {
		return null
	}

	return 42
}