extern sealed class String {
	length: Number
	startsWith(value: String): Boolean
	trim(): String
}

func foobar(lines: Array<String>) {
	let line

	for const i from 0 til lines.length {
		if (line = lines[i].trim()).length != 0 {
			if line.startsWith('foobar') {
			}
		}
	}
}