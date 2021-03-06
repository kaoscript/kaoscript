extern sealed class RegExp
extern sealed class String

disclose RegExp {
	exec(str: String): Array<String?>?
}

impl String {
	foobar() => this
}

const regex = /foo/

if const match = regex.exec('foobar') {
	if match[0]? {
		match[0].foobar()
	}
}
