async func foo(x, y) => x - y

async func bar() {
	try {
		var dyn d = await foo(42, 24)
		var dyn e = await foo(4, 2)

		return d * e
	}
	catch {
		return 0
	}
}