extern console

func foobar(begin, ...args, end: Array) {
	console.log('Array')
}
func foobar(begin, ...args, end: String) {
	console.log('String')
}
func foobar(begin, ...args, end) {
	console.log('Any')
}

export foobar