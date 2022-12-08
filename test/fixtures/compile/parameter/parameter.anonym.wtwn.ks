extern console

func foo(data, _: Object?, name: String = data.name) {
	console.log(name)
}