async func foo(x, y) {
}

async func bar() {
	var dyn d = 0
	
	d = await foo(42, 24)
	
	return d * 3
}