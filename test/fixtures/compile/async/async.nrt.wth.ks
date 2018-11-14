extern class Error

async func foo(bar, qux) ~ Error {
	throw new Error('baaaad!')
}