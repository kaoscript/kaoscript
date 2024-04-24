extern console

func foobar(text: String) {
	while var data ?= quxbaz(text) {
		console.log(`\(data)`)
	}
}

func quxbaz(text: String): String? => text