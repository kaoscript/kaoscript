func getIndex() => 0

func translate(statements, extending) {
	let index = 1
	if (index = getIndex()) == -1 && extending {

	}

	for statement in statements {
		statement.analyse()
	}
}