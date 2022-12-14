extern console

func foobar(): String => 'foobar'

if var mut x: String ?= foobar() {
	console.log(`\(x)`)
}