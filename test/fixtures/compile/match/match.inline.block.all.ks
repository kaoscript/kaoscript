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
			pick 30
		}
		.red {
			pick 31
		}
		.green {
			pick 32
		}
		.yellow {
			pick 33
		}
		.blue {
			pick 34
		}
		.magenta {
			pick 35
		}
		.cyan {
			pick 36
		}
		.white {
			pick 37
		}
		else {
			pick 39
		}
	}

	var bgCode = match bg {
		.black {
			pick 30
		}
		.red {
			pick 31
		}
		.green {
			pick 32
		}
		.yellow {
			pick 33
		}
		.blue {
			pick 34
		}
		.magenta {
			pick 35
		}
		.cyan {
			pick 36
		}
		.white {
			pick 37
		}
		else {
			pick 39
		}
	}

	return `\(fgCode);\(bgCode)m`
}