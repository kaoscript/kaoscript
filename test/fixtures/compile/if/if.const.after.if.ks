extern console

func foobar() {
	let data = 42

	if true {
		if const data = quxbaz() {
			console.log(data)
		}

		console.log(data)
	}

	console.log(data)
}

func quxbaz() {

}