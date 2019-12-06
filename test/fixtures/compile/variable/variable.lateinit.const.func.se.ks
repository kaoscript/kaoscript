extern console

impl Number {
	toString(): String => `\(this)`
}

impl String {
	toString(): String => this
}

lateinit const x

func foobar() {
	lateinit const x

	x = 'foobar'

	console.log(`\(x.toString())`)
}

x = 42

console.log(`\(x.toString())`)