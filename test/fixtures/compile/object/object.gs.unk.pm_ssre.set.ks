extern console

func foobar(o: { color: String, ... }) {
	console.log(`\(o.name)`)

	o.name = 'White'

	console.log(`\(o.name)`)
}