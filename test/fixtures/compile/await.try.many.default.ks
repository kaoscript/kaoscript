func foo(x, y) async => x - y

func bar() async {
	let d, e
	
	try {
		d = await foo(42, 24)
		e = await foo(4, 2)
	}
	catch {
		d = 0
		e = 1
	}
	
	return d * e
}