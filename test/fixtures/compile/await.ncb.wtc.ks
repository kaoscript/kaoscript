func foo(x, y) async => x - y

func bar() async {
	try {
		let d = await foo(42, 24)
		
		return d * 3
	}
	catch {
		return 0
	}
}