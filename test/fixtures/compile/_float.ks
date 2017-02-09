extern parseFloat

export let Float := {
	parse(value = null): Number {
		return parseFloat(value)
	}
}