async func foo(x, y) => x - y

async func bar() {
	try {
		var dyn d = await foo(42, 24)
		
		return d * 3
	}
	
	return 0
}