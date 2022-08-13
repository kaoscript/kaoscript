extern console

func foobar(values: Array<String>) {
	var args = [...values]
	
	console.log(`\(args[0])`)
}