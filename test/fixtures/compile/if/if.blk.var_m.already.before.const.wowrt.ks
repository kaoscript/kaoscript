extern console

func foobar() => 'foobar'

var x = 'barfoo'

console.log(`\(x)`)

if #[overwrite] var mut x ?= foobar() {
	console.log(`\(x)`)
}

console.log(`\(x)`)