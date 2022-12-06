require expect: func

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
	lines(): String[] {
		if var lines ?= this.match(/[^\r\n]+/g) {
			return filter(lines)
		}

		return []
	}
}

expect('foobar'.lines()).to.eql(['foobar'])
expect('\nfoobar'.lines()).to.eql(['foobar'])
expect('foobar\n'.lines()).to.eql(['foobar'])
expect('foo\nbar'.lines()).to.eql(['foo', 'bar'])
expect('foo\n\nbar'.lines()).to.eql(['foo', 'bar'])