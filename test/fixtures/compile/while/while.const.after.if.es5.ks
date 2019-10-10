#![target(ecma-v5)]

extern console

func foobar() {
	let data = 42

	if true {
		while const data = quxbaz() {
			console.log(data)
		}

		console.log(data)
	}

	console.log(data)
}

func quxbaz() {

}