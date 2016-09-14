extern parseInt

export let Integer := {
	parse(value?, radix?) {
		return parseInt(value, radix)
	}
}