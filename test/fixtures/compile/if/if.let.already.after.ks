extern console

func foobar() => 'foobar'

if var x ?= foobar() {
	console.log(`\(x)`)
}

var dyn x

console.log(`\(x)`)