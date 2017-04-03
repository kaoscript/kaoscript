extern parseFloat

export let Float := {
	parse(value = null): Number {
		return parseFloat(value)
	}
}
/* export namespace Float {
	parse(value = null): Number {
		return parseFloat(value)
	}
} */