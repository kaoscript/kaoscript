func foobar(data: { object: String? }) {
	if ?data.object -> quxbaz(data.object) {
	}
}

func quxbaz(data: String): Boolean {
	return true
}