extern console

class Foobar {
	foobar(x: String): String => 'quxbaz'
	foobar(x: Number): Number => 42
	quxbaz(a) {
		console.log(`\(this.foobar('foo'))`)

		console.log(`\(this.foobar(0))`)

		console.log(`\(this.foobar(a))`)
	}
}