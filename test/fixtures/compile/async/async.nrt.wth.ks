extern class Error

async func foo(bar, qux) ~ Error {
	throw Error.new('baaaad!')
}