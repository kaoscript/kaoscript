extern console

func foobar(...args, value: Array) {
	console.log('Array')
}
func foobar(...args, value: String) {
	console.log('String')
}

export foobar