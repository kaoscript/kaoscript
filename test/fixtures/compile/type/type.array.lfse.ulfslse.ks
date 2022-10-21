type RegExpExecArray = Array<String?> & {
    index: Number
    input: String
}

disclose String {
	match(regexp: RegExp): RegExpExecArray?
}

func filter(match: RegExpExecArray): Array<String> {
	var result = []

	for var line in match {
		if ?line {
			result.push(line)
		}
	}

	return result
}

impl String {
	lines(): Array<String> {
		if var lines ?= this.match(/[^\r\n]+/g) {
			return filter(lines)
		}

		return []
	}
}