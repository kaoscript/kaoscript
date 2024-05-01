extern console, foo

if foo?.bar() + 'world' == 'hello' + foo?.qux() {
	console.log(foo)
}