extern sealed class EvalError

class MyError extends EvalError {

}

export func foo() ~ MyError {

}