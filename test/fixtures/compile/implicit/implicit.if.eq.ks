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

func print(color: ANSIColor) {
	if color == .BLACK {
		echo('black')
	}
}