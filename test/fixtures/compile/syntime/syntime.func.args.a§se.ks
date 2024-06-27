extern x, y

syntime func myMacro(operator: Ast(Literal)) {
	quote {
		x #w(operator.value) y
	}
}

myMacro('==')