func foobar(value: Number | String): Number? {
	match value {
		is String {
			echo(`\(value)`)

			return null
		}
		else {
			return value
		}
	}
}