extern console

async func foo(x, y) => x - y

async func bar() {
	let x = -1
	
	try {
		x = await foo(await foo(42, 24), await foo(4, 2))
	}
	catch {
		x = await foo(2, 4)
	}
	finally {
		x = await foo(33, x)
	}
	
	return x
}