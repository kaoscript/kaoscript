extern sealed class RegExp

disclose RegExp {
	exec(str: String): Array<String?>?
}

func foobar(x: Array<String?>) {
}

const regex = /foo/

if const match = regex.exec('foobar') {
	foobar(match)
}