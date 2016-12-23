extern console

func foo() {
	return false
}

until x = foo() {
	console.log(x)
}