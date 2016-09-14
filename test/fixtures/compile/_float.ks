extern parseFloat

export let Float := {
	parse(value?) -> Number {
		return parseFloat(value)
	}
}