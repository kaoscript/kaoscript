extern console

var foo = { bar: 'hello', baz: 3 }
var bar = 'foo'

{bar, baz} = foo

console.log(bar, baz)