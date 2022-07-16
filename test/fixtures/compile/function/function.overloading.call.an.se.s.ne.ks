extern console

func foobar(x?) {
}

func foobar(x: String): String => x

console.log(`\(foobar('foo'))`)

console.log(`\(foobar(null))`)