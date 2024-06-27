extern x, y

syntime func myMacro(operators: Ast[]) {
	for var operator in operators {
		quote {
			x #w(operator.value) y
		}
	}
}

syntime {
	var ast = myMacro(['==', '!='])

	quote #(ast)
}