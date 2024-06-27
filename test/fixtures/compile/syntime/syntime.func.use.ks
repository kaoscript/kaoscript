syntime func using(id: Ast(Identifier), exp: Ast(Expression)) {
	quote {
		(() => {
			var dyn #(id) = 42
			return #(exp)
		})()
	}
}

var dyn four = using(a, a / 10)