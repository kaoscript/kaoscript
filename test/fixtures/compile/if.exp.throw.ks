extern class Error

func foo(x) ~ Error {
	throw new Error() if x
}