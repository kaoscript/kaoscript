async func foo(x, y) => x - y

async func bar() {
	let d
	
	try {
		let x = 42
		let y = 24
		
		d = await foo(x, y)
		
		d *= 3
	}
	catch {
		d = 0
	}
	
	return d
}