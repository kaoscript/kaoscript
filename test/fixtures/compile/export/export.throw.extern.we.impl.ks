extern systemic class SyntaxError

impl SyntaxError {
	foo(): string => 'bar'
}

func foo() ~ SyntaxError {

}

export foo, SyntaxError