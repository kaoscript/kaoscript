extern class Error

async func foo(bar, qux) ~ Error {
	if qux == 0 {
		throw Error.new('baaaad!')
	}
	else {
		return `\(qux)-\(bar)`
	}
}