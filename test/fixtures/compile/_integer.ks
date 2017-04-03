extern parseInt

export const Integer = {
	parse(value = null, radix = null) {
		return parseInt(value, radix)
	}
}
/* export namespace Float {
	parse(value = null, radix = null) {
		return parseInt(value, radix)
	}
} */