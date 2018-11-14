extern console

async func foo() {
	return 1
}

let a = await foo()

console.log(a)