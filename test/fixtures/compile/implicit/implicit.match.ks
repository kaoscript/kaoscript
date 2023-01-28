enum ANSIColor {
	BLACK
	RED
	GREEN
	YELLOW
	BLUE
	MAGENTA
	CYAN
	WHITE
	DEFAULT
}

func color(fg: ANSIColor, bg: ANSIColor): String {
	var late fgCode: Number

	match fg {
		.BLACK		=> fgCode = 30
		.RED		=> fgCode = 31
		.GREEN		=> fgCode = 32
		.YELLOW		=> fgCode = 33
		.BLUE		=> fgCode = 34
		.MAGENTA	=> fgCode = 35
		.CYAN		=> fgCode = 36
		.WHITE		=> fgCode = 37
		else		=> fgCode = 39
	}

	return `\(fgCode);m`
}