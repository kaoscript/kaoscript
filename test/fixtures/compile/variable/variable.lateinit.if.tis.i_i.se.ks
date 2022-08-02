extern console

impl Number {
	toString(): String => `\(this)`
}

impl String {
	toString(): String => this
}

var late x

if true {
	x = 42

	x = 24

	console.log(`\(x.toString())`)
}
else {
	x = 'quxbaz'

	console.log(`\(x.toString())`)
}

console.log(`\(x.toString())`)