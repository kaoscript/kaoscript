extern console

func foobar(value: Array, ...args) {
	console.log('Array')
}
func foobar(value: String, ...args) {
	console.log('String')
}

export foobar