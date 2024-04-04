#![libstd(off)]

extern {
	func parseFloat(...): Number
	func parseInt(...): Number
}

disclose RegExp {
	source: String
	global: Boolean
	ignoreCase: Boolean
	multiline: Boolean
	exec(str: String, index: Number = 0): RegExpExecArray?
	test(str: String): Boolean
	toString(): String
}

type RegExpExecArray = Array<String?> & {
    index: Number
    input: String
}

impl String {
	lines(emptyLines = false): Array {
		if this.length == 0 {
			return []
		}
		else if emptyLines {
			return this.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split('\n')
		}
		else {
			return this.match(/[^\r\n]+/g) ?? []
		}
	}
	lower(): String => this.toLowerCase()
	toFloat(): Number => parseFloat(this)
	toInt(base = 10): Number => parseInt(this, base)
}

export RegExp, RegExpExecArray, String