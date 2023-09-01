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
		@quxbaz(.YELLOW, true)
	}
	quxbaz(color: ANSIColor = .BLACK, flag: Boolean) {
	}
}