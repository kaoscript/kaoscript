syntime func myMacro(operator: String | [String, Ast(Expression)]) {
	if operator is Array {
		quote {
			#(operator[0])
			"#(operator[1])"
		}
	}
	else {
		quote {
			#(operator)
		}
	}
}

myMacro('!=')
myMacro(['!=', x != y])