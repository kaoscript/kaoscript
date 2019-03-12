extern console

func foobar(): String => 'foobar'

if let x: String = foobar() {
	console.log(`\(x)`)
}