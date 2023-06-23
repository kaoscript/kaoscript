enum ANSIColor {
	black
	red
	green
	yellow
	blue
	magenta
	cyan
	white
	default
}

func color(fg: ANSIColor, bg: ANSIColor): String {
	var fgCode = match fg {
		.black {
			set 30
		}
		.red {
			set 31
		}
		.green {
			set 32
		}
		.yellow {
			set 33
		}
		.blue {
			set 34
		}
		.magenta {
			set 35
		}
		.cyan {
			set 36
		}
		.white {
			set 37
		}
		else {
			set 39
		}
	}

	var bgCode = match bg {
		.black {
			set 30
		}
		.red {
			set 31
		}
		.green {
			set 32
		}
		.yellow {
			set 33
		}
		.blue {
			set 34
		}
		.magenta {
			set 35
		}
		.cyan {
			set 36
		}
		.white {
			set 37
		}
		else {
			set 39
		}
	}

	return `\(fgCode);\(bgCode)m`
}