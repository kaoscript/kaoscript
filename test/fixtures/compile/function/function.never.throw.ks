class FoobarError extends Error {

}

func foobar(): never ~ FoobarError {
	throw new FoobarError()
}

export FoobarError, foobar