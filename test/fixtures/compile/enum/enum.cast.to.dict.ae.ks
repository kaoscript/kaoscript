enum Color<String> {
	Red
	Green
	Blue
}

const aliases: Dictionary = {
	r: Color::Red
}

func foobar(x: String) {
	if aliases[x] == Color::Red {
	}
}