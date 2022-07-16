extern {
	func parseFloat(...): Number
}

export namespace Float {
	export func parse(value = null): Number => parseFloat(value)
}