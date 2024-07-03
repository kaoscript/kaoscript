syntime func myMacro(name: Ast(Identifier, Literal)) {
	if name is Ast(Identifier) {
		quote "Identifier"
	}
	else {
		quote "Literal"
	}
}

myMacro(BINARY_OPERATOR)