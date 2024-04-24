extern console

func foobar(text: String) {
	while var mut data ?= quxbaz(text) {
		console.log(`\(data)`)
	}

	while var mut data ?= quxbaz(text) {
		console.log(`\(data)`)
	}
}

func quxbaz(text: String): String? => text