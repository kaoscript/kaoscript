extern system class String {
	camelize(): String
	toUpperCase(): String
}

func process(input: String): String {
	return input
		|> _.camelize()
		|> _.toUpperCase()
}