extern console

func foobar(values: String[]) {
	var args = [...values]
	
	console.log(`\(args[0])`)
}