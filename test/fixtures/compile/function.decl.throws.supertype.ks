extern class Error
extern class RangeError extends Error
extern class SyntaxError extends Error

func foo(bar) ~ SyntaxError, RangeError {
}

try {
	foo()
}
on Error {
}