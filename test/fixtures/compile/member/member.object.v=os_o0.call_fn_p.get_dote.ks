func foobar() {
	var values: String{} = {}

	quxbaz(values)

	echo(`\(values.foo)`)
}

func quxbaz(values) {
	values['foo'] = 'foo'
}