extern x, y

syntime func myMacro(operators: String[]) {
	for var operator in operators {
		quote {
			x #w(operator) y
		}
	}
}

myMacro(['==', '!='])