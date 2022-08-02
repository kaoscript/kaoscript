extern sealed class RegExp

disclose RegExp {
	exec(str: String): Array<String?>?
}

func foobar(x: Array<String?>) {
}

var regex = /foo/

if var match = regex.exec('foobar') {
	foobar(match)
}