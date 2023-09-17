extern console

impl Number {
	toString(): String => `\(this)`
}

impl String {
	toString(): String => this
}

func foobar() {
	var late x

	x = 'foobar'

	x = 'quxbaz'

	console.log(`\(x.toString())`)
}