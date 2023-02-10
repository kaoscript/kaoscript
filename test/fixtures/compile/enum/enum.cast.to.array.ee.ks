enum Color<String> {
	Red
	Green
	Blue
}

var aliases: Array<Color> = [Color.Red]

func foobar() {
	if aliases[0] == Color.Red {
	}
}