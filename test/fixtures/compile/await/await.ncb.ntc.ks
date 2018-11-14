async func foo(x, y) => x - y

async func bar() {
	let d = await foo(42, 24)
	
	return d * 3
}