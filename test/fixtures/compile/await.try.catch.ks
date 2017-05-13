func foo(x, y) async => x - y

func bar() async {
	let d
	
	try {
		d = await foo(42, 24)
	}
	catch {
		d = 0
	}
	
	return d
}