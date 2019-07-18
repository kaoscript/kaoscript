extern console

func foobar(...args, value: Array) {
	console.log('Array')
}
func foobar(...args, value: String) {
	console.log('String')
}
func foobar(...args, value) {
	console.log('Any')
}

export foobar