extern class Error

async func foo(bar, qux) ~ Error {
	if qux == 0 {
		throw new Error('baaaad!')
	}
	else {
		return `\(qux)-\(bar)`
	}
}