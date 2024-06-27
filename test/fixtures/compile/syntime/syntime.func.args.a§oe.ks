extern x, y

syntime func myMacro(operator: Ast(Operator)) {
	quote {
		x #(operator) y
	}
}

myMacro!(==)