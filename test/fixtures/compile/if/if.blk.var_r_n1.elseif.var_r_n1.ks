extern console

func foobar() => null
func quxbaz() => 'quxbaz'

if var x ?= foobar() {
	console.log(`\(x)`)
}
else if var x ?= quxbaz() {
	console.log(`\(x)`)
}