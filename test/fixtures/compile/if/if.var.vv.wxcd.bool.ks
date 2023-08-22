type Data = {
	test(): Boolean
	text(): String
}

func foobar(resolve: (): Data?) {
	if var value ?= resolve(); value.test() {
		echo(`\(value.text())`)
	}
}