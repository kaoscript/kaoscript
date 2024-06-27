extern x, y

syntime func myMacro(operators: Ast(Operator)[]) {
	for var operator in operators {
		quote {
			x #(operator) y
		}
	}
}

syntime {
	var ast = myMacro!([==, !=])

	quote #(ast)
}