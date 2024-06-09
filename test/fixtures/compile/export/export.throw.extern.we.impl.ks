extern system class EvalError

impl EvalError {
	foo(): string => 'bar'
}

func foo() ~ EvalError {

}

export foo, EvalError