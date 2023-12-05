extern test

impl Number {
	toString(): String => `\(this)`
}

impl String {
	toString(): String => this
}

var late x

if test {
	x = 'foobar'

	echo(`\(x.toString())`)
}
else {
	x = 42

	echo(`\(x.toString())`)
}

echo(`\(x.toString())`)