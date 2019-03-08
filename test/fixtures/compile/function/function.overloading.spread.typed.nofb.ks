extern console

func foobar(...args: Array<Array>) {
	console.log('Array')
}
func foobar(...args: Array<String>) {
	console.log('String')
}

export foobar