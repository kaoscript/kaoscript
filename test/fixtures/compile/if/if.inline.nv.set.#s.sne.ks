func foobar(name: String?) {
	var x: String =
		if ?name {
			set name
		}
		else {
			set 'clubs'
		}
}