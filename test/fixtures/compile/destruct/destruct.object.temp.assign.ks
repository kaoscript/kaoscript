func parse(line, rules?) {
	var tokens = []

	return {
		tokens
		rules
	}
}

func foobar(lines) {
	var dyn tokens, rules

	for var line in lines {
		{tokens, rules} = parse(line, rules)
	}
}