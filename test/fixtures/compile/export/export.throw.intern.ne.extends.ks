extern sealed class SyntaxError

class MyError extends SyntaxError {

}

export func foo() ~ MyError {

}