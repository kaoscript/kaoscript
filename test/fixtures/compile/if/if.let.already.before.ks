extern console

func foobar(): String => 'foobar'

let x = 'foobar'

if let x = foobar() {
	console.log(`\(x)`)
}