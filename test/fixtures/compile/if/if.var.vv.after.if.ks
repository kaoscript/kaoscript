extern console

func foobar() {
	var dyn data = 42

	if true {
		if var data ?= quxbaz() {
			console.log(data)
		}

		console.log(data)
	}

	console.log(data)
}

func quxbaz() {

}