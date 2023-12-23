type Foobar = {
	flag: Boolean
	name: String
}

func foobar(value) {
	if value is Foobar -> value.flag {
		echo(`\(value.name)`)
	}
}