extern {
	func parseInt(...): Number
}

export namespace Integer {
	export func parse(value = null, radix = null): Number => parseInt(value, radix)
}