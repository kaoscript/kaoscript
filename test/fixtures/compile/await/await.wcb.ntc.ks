async func foo(x, y) => x - y

func bar(cb) {
	let d = await foo(42, 24)
	
	cb(d ?? 0)
}