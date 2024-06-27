syntime func myMacro(...operators: String | Ast(Identifier)) {
	for var operator in operators {
		if operator is String {
			quote {
				#(operator)
			}
		}
		else {
			quote {
				"#(operator)"
			}
		}
	}
}

myMacro(EXCLAMATION_EQUALS, '!=')