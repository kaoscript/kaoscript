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
		{tokens, rules} = parse(line, rules)
	}
}