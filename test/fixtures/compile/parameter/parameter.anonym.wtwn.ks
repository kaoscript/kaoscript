extern console

func foo(data, _: Dictionary?, name: String = data.name) {
	console.log(name)
}