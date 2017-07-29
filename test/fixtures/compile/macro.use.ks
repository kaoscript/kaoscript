macro using(id: Identifier, exp: Expression) {
	macro {
		(() => {
			let #id = 42
			return #exp
		})()
	}
}

let four = using!(a, a / 10)