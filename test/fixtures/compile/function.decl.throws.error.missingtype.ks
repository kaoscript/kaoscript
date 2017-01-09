extern SyntaxError: class, RangeError: class

func foo(bar) ~ SyntaxError, RangeError {
}

try {
	foo()
}
on SyntaxError {
}