func foobar(person) {
	with person {
		echo(`Hello \(.firstname) \(.lastname)`)
	}
}