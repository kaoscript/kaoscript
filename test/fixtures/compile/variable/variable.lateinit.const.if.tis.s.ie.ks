extern console

impl Number {
	toString(): String => `\(this)`
}

impl String {
	toString(): String => this
}

lateinit const x

if true {
	x = 'foobar'

	console.log(`\(x.toString())`)
}
else {
	x = 42

	console.log(`\(x.toString())`)
}

console.log(`\(x.toString())`)