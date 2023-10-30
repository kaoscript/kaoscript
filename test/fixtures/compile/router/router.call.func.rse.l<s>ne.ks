func foobar(...values: String) {
}


func quxbaz(values: String[]?) {
	foobar(...?values)
}