extern console

func foobar() => null
func quxbaz() => 'quxbaz'

if const x = foobar() {
	console.log(`\(x)`)
}
else if const y = quxbaz() {
	console.log(`\(y)`)
}