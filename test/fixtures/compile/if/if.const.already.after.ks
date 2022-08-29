extern console

func foobar(): String => 'foobar'

if var x ?= foobar() {
	console.log(`\(x)`)
}

var dyn x

console.log(`\(x)`)