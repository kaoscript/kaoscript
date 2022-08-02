async func foo(x, y) => x - y

async func bar() {
	var dyn d = 0
	
	try {
		d = await foo(42, 24)
		
		d *= 3
	}
	
	return d
}