func getIndex() => 0

func translate(statements, extending) {
	var dyn index = 1
	if (index <- getIndex()) == -1 && extending {

	}

	var dyn statement

	for statement in statements {
		statement.analyse()
	}
}