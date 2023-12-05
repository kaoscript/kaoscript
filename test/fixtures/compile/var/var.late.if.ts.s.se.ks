extern test

impl String {
	toString(): String => this
}

var late x

if test {
	x = 'foobar'

	echo(`\(x.toString())`)
}
else {
	x = 'quxbaz'

	echo(`\(x.toString())`)
}

echo(`\(x.toString())`)