extern sealed class RegExp
extern sealed class String

disclose RegExp {
	exec(str: String): Array<String?>?
}

impl String {
	foobar() => this
}

var regex = /foo/

if var match = regex.exec('foobar') {
	if match[0]? {
		match[0].foobar()
	}
}
