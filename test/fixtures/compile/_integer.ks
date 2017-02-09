extern parseInt

export let Integer := {
	parse(value = null, radix = null) {
		return parseInt(value, radix)
	}
}