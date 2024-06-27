syntime func myMacro(operators: [Ast(Identifier), Ast(Expression)]) {
	quote {
		"#(operators[0])"
		"#(operators[1])"
	}
}

myMacro([EXCLAMATION_EQUALS, x != y])