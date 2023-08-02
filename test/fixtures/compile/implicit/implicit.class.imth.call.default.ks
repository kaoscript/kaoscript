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

class Foobar {
	foobar() {
		@quxbaz(.BLACK)
	}
	quxbaz(color: ANSIColor) {
	}
}