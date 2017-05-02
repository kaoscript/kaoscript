extern console

func foo() async {
	return 1
}

let a = await foo()

console.log(a)