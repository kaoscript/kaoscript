extern sealed class String {
	length: Number
	trim(): String
}

func foobar(lines: Array<String>) {
	var dyn line

	for var i from 0 to~ lines.length {
		if (line <- lines[i].trim()).length != 0 || (line <- true) {
			if line {
			}
		}
	}
}