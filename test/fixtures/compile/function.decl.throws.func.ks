extern class Error

func foo(bar) ~ Error {
}

func bar() ~ Error {
	foo()
}