extern sealed class RegExp

disclose RegExp {
	exec(str: String): Array<String?>?
}

func foobar(x: Number?) {
}

const regex = /foo/

if const match = regex.exec('foobar') {
	foobar(match[0])
}