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

	x = 42

	console.log(`\(x.toString())`)
}