syntime func myMacro(operators: []) {
	for var operator in operators {
		quote {
			x #w(operator) y
		}
	}
}

syntime echo(myMacro(['==', '!=']):>(String))