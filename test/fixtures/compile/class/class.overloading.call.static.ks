extern console

class Foobar {
	static foobar(x: String): String => 'quxbaz'
	static foobar(x: Number): Number => 42
}

func foobar(a) {
	console.log(`\(Foobar.foobar('foo'))`)

	console.log(`\(Foobar.foobar(0))`)

	console.log(`\(Foobar.foobar(a))`)
}