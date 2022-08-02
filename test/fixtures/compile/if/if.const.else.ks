extern console

func foobar() => null
func quxbaz() => 'quxbaz'

if var x = foobar() {
	console.log(`\(x)`)
}
else if var y = quxbaz() {
	console.log(`\(y)`)
}