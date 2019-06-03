#![target(ecma-v5)]

func foobar(a, b, c) {
	let x

	if a {
		x = {
			b
			c: c
		}
	}
}