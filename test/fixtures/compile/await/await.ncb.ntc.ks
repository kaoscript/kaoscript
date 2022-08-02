async func foo(x, y) => x - y

async func bar() {
	var dyn d = await foo(42, 24)

	return d * 3
}