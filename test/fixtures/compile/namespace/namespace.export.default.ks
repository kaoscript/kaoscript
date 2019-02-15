extern parseFloat

export namespace Float {
	export {
		func toFloat(value: String): Number => parseFloat(value)
		func toString(value: Number): String => value.toString()
	}
}