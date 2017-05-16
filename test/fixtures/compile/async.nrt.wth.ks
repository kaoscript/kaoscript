extern class Error

func foo(bar, qux) async ~ Error {
	throw new Error('baaaad!')
}