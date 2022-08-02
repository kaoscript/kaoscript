async func foo(x, y) => x - y

async func bar() {
	var dyn d
	
	try {
		d = await foo(42, 24)
	}
	catch {
		d = 0
	}
	
	return d
}