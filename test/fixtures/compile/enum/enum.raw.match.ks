enum Color {
	Red
	Green
	Blue
}

func foobar(data) {
	for var { kind } in data {
		match Color(kind) {
			.Red {
				echo('red')
			}
		}
	}
}