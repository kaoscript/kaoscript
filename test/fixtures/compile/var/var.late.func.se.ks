extern console

impl Number {
	toString(): String => `\(this)`
}

impl String {
	toString(): String => this
}

var late x

func foobar() {
	var late x

	x = 'foobar'

	console.log(`\(x.toString())`)
}

x = 42

console.log(`\(x.toString())`)