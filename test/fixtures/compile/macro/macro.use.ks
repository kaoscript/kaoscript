macro using(id: Identifier, exp: Expression) {
	macro {
		(() => {
			var dyn #(id) = 42
			return #(exp)
		})()
	}
}

var dyn four = using!(a, a / 10)