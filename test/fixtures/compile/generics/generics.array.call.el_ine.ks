extern sealed class RegExp

disclose RegExp {
	exec(str: String): Array<String?>?
}

func foobar(x: Number?) {
}

var regex = /foo/

if var match ?= regex.exec('foobar') {
	foobar(match[0])
}