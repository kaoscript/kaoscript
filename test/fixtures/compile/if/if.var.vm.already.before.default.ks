extern console

func foobar() => 'foobar'

var dyn x = 'barfoo'

console.log(`\(x)`)

if var mut x ?= foobar() {
	console.log(`\(x)`)
}

console.log(`\(x)`)