enum Color<String> {
	Red
	Green
	Blue
}

const aliases: Dictionary<String> = {
	r: Color::Red
}

func foobar(x: String) {
	if aliases[x] == Color::Red {
	}
}