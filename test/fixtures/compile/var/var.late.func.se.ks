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

	console.log(`\(x.toString())`)
}