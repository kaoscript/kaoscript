extern sealed class RegExp

disclose RegExp {
	exec(str: String): Array<String?>?
}

func foobar(x: Array<Number>?) {
}

var regex = /foo/

var match = regex.exec('foobar')

foobar(match)
