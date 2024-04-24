extern console

func foobar() => 'foobar'

if var mut x ?= foobar() {
	console.log(`\(x)`)
}

var dyn x

console.log(`\(x)`)