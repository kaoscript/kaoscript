extern sealed class String {
	length: Number
	startsWith(value: String): Boolean
	trim(): String
}

func foobar(lines: Array<String>) {
	var dyn line

	for var i from 0 til lines.length {
		if (line = lines[i].trim()).length != 0 {
			if line.startsWith('foobar') {
			}
		}
	}
}