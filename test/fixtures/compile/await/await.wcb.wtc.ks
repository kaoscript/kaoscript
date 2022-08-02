async func foo(x, y) => x - y

func bar(cb) {
	try {
		var dyn d = await foo(42, 24)
		
		cb(d)
	}
	catch {
		cb(0)
	}
}