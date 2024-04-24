enum Color<String> {
	Red
	Green
	Blue
}

func toColor(value: String): Color {
	var color = Color('red')!?

	return color
}