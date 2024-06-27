syntime func myMacro(operator: Ast(Identifier) | [Ast(Identifier), Ast(Expression)]) {
	if operator is Array {
		quote {
			"#(operator[0])"
			"#(operator[1])"
		}
	}
	else {
		quote {
			"#(operator)"
		}
	}
}

myMacro(EXCLAMATION_EQUALS)
myMacro([EXCLAMATION_EQUALS, x != y])