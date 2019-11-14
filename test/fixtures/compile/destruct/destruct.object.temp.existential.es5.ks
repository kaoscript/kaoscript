#![target(ecma-v5)]

func parse(line, rules?) {
	const tokens = []

	return {
		tokens
		rules
	}
}

func foobar(lines) {
	let tokens, rules

	for const line in lines {
		if {tokens, rules} ?= parse(line, rules) {

		}
	}
}