extern console

type Data = {
	test(): Boolean
	text(): String
}

func foobar(resolve: (): Data?) {
	if var value ?= resolve(); value.test() {
		console.log(`\(value.text())`)
	}
}