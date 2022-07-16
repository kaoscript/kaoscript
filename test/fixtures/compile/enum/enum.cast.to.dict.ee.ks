enum Color<String> {
	Red
	Green
	Blue
}

const aliases: Dictionary<Color> = {
	r: Color::Red
}

func foobar(x: String) {
	if aliases[x] == Color::Red {
	}
}