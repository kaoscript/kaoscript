extern console

func foobar(...args: Array) {
	console.log('Array')
}
func foobar(...args: String) {
	console.log('String')
}
func foobar(...args) {
	console.log('Any')
}

export foobar