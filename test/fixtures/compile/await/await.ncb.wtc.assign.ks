#![bin]

extern console

async func foo(x, y) => x - y

async func bar() {
	try {
		d = await foo(42, 24)

		console.log(d)

		return d * 3
	}
	catch {
		return 0
	}
}

console.log(await bar())