async func foo(x, y) => x - y

async func bar() {
	try {
		let d = await foo(42, 24)
		
		return d * 3
	}
	catch {
		return 0
	}
}