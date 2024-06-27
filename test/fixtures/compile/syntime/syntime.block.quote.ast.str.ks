extern x, y

syntime func myMacro(operators: []) {
	for var operator in operators {
		quote {
			x #w(operator) y
		}
	}
}

syntime {
	var ast = myMacro(['==', '!='])

	quote #(ast)
}