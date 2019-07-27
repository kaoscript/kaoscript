extern SyntaxError: class, RangeError: class

func foo(bar) ~ SyntaxError, RangeError {
}

try {
	foo(42)
}
on SyntaxError {
}