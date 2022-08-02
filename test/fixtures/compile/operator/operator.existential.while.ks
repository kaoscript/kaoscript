extern sealed class RegExp

type RegExpExecArray = Array<String?> & {
    index: Number
    input: String
}

disclose RegExp {
	exec(str: String): RegExpExecArray?
	test(str: String): Boolean
	toString(): String
}

func foobar(text: String, pattern: RegExp) {
	var dyn founds: Array<RegExpExecArray> = []
	var dyn data: RegExpExecArray

	while data ?= pattern.exec(text) {
		founds.push(data)
	}
}