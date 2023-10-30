extern func push(...args?)

func foobar(a, b) {
	push(0, 4, ...a, 1, ...b, 7, 9)
}