extern console

func foobar(text: String) {
	while let data = quxbaz(text) {
		console.log(`\(data)`)
	}

	while let data = quxbaz(text) {
		console.log(`\(data)`)
	}
}

func quxbaz(text: String): String => text