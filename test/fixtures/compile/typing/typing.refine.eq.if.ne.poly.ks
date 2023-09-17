class Foobar {
	private {
		@value: String = ''
	}
	foobar(mut value: String?) {
		var mut file: String? = null
		if !?value {
			file = value = ''
		}
		@value = value
	}
}
