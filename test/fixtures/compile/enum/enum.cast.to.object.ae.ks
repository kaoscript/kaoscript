enum Color<String> {
	Red
	Green
	Blue
}

var aliases: Object = {
	r: Color::Red
}

func foobar(x: String) {
	if aliases[x] == Color::Red {
	}
}