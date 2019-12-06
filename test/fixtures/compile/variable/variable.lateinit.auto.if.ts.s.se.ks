extern console

impl String {
	toString(): String => this
}

lateinit auto x

if true {
	x = 'foobar'

	console.log(`\(x.toString())`)
}
else {
	x = 'quxbaz'

	console.log(`\(x.toString())`)
}

console.log(`\(x.toString())`)