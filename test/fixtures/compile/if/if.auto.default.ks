extern console

func foobar(): String => 'foobar'

if auto x = foobar() {
	console.log(`\(x)`)
}