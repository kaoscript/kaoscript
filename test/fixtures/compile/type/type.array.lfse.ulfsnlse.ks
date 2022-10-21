type RegExpExecArray = Array<String?> & {
    index: Number
    input: String
}

disclose String {
	match(regexp: RegExp): RegExpExecArray?
}

impl String {
	lines(): Array<String> {
		return this.match(/[^\r\n]+/g) ?? []
	}
}