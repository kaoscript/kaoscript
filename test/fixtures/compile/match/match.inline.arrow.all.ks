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
		.black => 30
		.red => 31
		.green => 32
		.yellow => 33
		.blue => 34
		.magenta => 35
		.cyan => 36
		.white => 37
		else => 39
	}

	var bgCode = match bg {
		.black => 40
		.red => 41
		.green => 42
		.yellow => 44
		.blue => 44
		.magenta => 45
		.cyan => 46
		.white => 47
		else => 49
	}

	return `\(fgCode);\(bgCode)m`
}