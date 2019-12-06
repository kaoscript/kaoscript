extern console

impl Number {
	toString(): String => `\(this)`
}

impl String {
	toString(): String => this
}

func foobar() {
	lateinit auto x

	x = 'foobar'

	x = 42

	console.log(`\(x.toString())`)
}