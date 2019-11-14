extern sealed class String {
	length: Number
	trim(): String
}

func foobar(lines: Array<String>) {
	let line

	for const i from 0 til lines.length {
		if (line = lines[i].trim()).length != 0 || (line = true) {
			if line {
			}
		}
	}
}