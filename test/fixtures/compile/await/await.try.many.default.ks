async func foo(x, y) => x - y

async func bar() {
	var dyn d, e
	
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