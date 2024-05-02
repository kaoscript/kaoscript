func foobar(datas) {
	var values = { [data.index]: data.value for var data in datas }

	return values['hello']
}