#![target(ecma-v5)]

extern console

func foobar() => 'foobar'

if let x = foobar() {
	console.log(`\(x)`)
}

let x

console.log(`\(x)`)