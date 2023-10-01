func foobar(person: { firstname: String, lastname: String }) {
	with person {
		echo(`Hello \(.firstname) \(.lastname)`)
	}
}