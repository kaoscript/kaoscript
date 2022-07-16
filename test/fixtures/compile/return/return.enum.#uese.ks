enum Color<String> {
	Red
	Green
	Blue
}

func foobar(): String {
	return quxbaz()
}

func quxbaz(): Color | String {
	return 'red'
}