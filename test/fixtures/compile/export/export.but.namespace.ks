extern {
	func parseFloat(...): Number

	#[rules(non-exhaustive)]
	systemic class Number {
		toString(): String
	}
}

export namespace Float {
	func toFloat(value: String): Number => parseFloat(value)
	func toString(value: Number): String => value.toString()

	export *
}