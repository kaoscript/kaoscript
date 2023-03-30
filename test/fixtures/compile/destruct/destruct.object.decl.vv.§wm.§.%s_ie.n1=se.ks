extern console

var foo = { bar: 'hello', baz: 3 }

var {mut bar, baz} = foo

bar = 'foo'

console.log(bar, baz)