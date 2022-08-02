extern console

async func foo() {
	return 1
}

var dyn a = await foo()

console.log(a)