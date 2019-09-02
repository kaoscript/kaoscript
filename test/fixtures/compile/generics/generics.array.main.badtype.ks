extern sealed class RegExp

disclose RegExp {
	exec(str: String): Array<String?>?
}

func foobar(x: Array<Number>?) {
}

const regex = /foo/

const match = regex.exec('foobar')

foobar(match)
