extern class Error

func foo(x) ~ Error {
	throw Error.new() if x
}