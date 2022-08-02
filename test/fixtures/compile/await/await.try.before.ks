async func foo(x, y) => x - y

async func bar() {
	var dyn d
	
	try {
		var dyn x = 42
		var dyn y = 24
		
		d = await foo(x, y)
		
		d *= 3
	}
	catch {
		d = 0
	}
	
	return d
}