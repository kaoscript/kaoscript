enum Color<String> {
	Red
	Green
	Blue
}

const aliases: Array = [Color::Red]

func foobar() {
	if aliases[0] == Color::Red {
	}
}