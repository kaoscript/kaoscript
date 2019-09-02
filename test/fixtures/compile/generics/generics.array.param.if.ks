extern sealed class RegExp

disclose RegExp {
	exec(str: String): Array<String?>?
}

func foobar(x: String) {
}

const regex = /foo/

if const match = regex.exec('foobar') {
	if match[0]? {
		foobar(match[0])
	}
}