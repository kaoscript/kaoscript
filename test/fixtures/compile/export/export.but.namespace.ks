extern parseFloat

export namespace Float {
	func toFloat(value: String): Number => parseFloat(value)
	func toString(value: Number): String => value.toString()

	export *
}