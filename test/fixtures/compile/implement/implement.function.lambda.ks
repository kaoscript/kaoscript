extern console

extern sealed class Function

impl Function {
	foo() => 'foo' + this()
}

console.log((() => 'bar').foo())