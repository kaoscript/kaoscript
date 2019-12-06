extern console

impl Number {
	toString(): String => `\(this)`
}

impl String {
	toString(): String => this
}

lateinit auto x

func foobar() {
	lateinit auto x

	x = 'foobar'

	console.log(`\(x.toString())`)
}

x = 42

console.log(`\(x.toString())`)