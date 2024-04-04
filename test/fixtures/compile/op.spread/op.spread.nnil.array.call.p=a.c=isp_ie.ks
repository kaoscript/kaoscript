extern func push(...args?)

func foobar(values) {
	push(0, ...values, 99)
}