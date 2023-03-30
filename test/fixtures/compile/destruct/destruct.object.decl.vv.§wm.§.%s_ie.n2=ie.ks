extern console

var foo = { bar: 'hello', baz: 3 }

var {mut bar, baz} = foo

baz = 0

console.log(bar, baz)