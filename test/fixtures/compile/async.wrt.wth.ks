extern class Error

func foo(bar, qux) async ~ Error {
	if qux == 0 {
		throw new Error('baaaad!')
	}
	else {
		return `\(qux)-\(bar)`
	}
}