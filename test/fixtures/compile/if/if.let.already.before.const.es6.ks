extern console

func foobar() => 'foobar'

const x = 'barfoo'

console.log(`\(x)`)

if let x = foobar() {
	console.log(`\(x)`)
}

console.log(`\(x)`)