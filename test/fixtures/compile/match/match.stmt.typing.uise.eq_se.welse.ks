func foobar(value: Number | String): Number? {
	match value {
		String {
			echo(`\(value)`)

			return null
		}
		else {
			return value
		}
	}
}