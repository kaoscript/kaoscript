extern x, y

syntime func myMacro(operators: Ast(Literal)[]) {
	for var operator in operators {
		quote {
			x #w(operator.value) y
		}
	}
}

myMacro(['==', '!='])