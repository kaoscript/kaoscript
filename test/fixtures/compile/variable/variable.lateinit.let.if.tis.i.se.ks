extern console

impl Number {
	toString(): String => `\(this)`
}

impl String {
	toString(): String => this
}

lateinit let x

if true {
	x = 42

	console.log(`\(x.toString())`)
}
else {
	x = 'quxbaz'

	console.log(`\(x.toString())`)
}

console.log(`\(x.toString())`)