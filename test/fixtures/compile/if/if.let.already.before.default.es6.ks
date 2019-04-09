extern console

func foobar(): String => 'foobar'

let x = 'barfoo'

console.log(`\(x)`)

if let x = foobar() {
	console.log(`\(x)`)
}

console.log(`\(x)`)