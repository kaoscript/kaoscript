class FoobarError extends Error {

}

func foobar(): never ~ FoobarError {
	throw FoobarError.new()
}

export FoobarError, foobar