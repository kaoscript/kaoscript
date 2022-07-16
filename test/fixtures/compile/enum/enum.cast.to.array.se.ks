enum Color<String> {
	Red
	Green
	Blue
}

const aliases: Array<String> = [Color::Red]

func foobar() {
	if aliases[0] == Color::Red {
	}
}