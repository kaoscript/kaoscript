extern console

extern sealed class Function

impl Function {
	foo() => 'foo' + this()
}

func bar() => 'bar'

console.log(bar.foo())