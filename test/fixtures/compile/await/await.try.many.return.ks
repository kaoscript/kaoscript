async func foo(x, y) => x - y

async func bar() {
	try {
		let d = await foo(42, 24)
		let e = await foo(4, 2)

		return d * e
	}
	catch {
		return 0
	}
}