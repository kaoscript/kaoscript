#![target(ecma-v5)]

extern console

func foobar() => 'foobar'

let x = 'barfoo'

console.log(`\(x)`)

if let x = foobar() {
	console.log(`\(x)`)
}

console.log(`\(x)`)