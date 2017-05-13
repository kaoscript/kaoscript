func foo(x, y) async => x - y

func bar(cb) {
	try {
		let d = await foo(42, 24)
		
		cb(d)
	}
	catch {
		cb(0)
	}
}