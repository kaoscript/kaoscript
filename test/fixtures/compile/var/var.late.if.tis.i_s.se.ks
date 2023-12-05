extern test

impl Number {
	toString(): String => `\(this)`
}

impl String {
	toString(): String => this
}

var late x

if test {
	x = 42

	x = 'foobar'

	echo(`\(x.toString())`)
}
else {
	x = 'quxbaz'

	echo(`\(x.toString())`)
}

echo(`\(x.toString())`)