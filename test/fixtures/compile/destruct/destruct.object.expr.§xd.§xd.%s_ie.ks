extern console

var foo = { bar: 'hello', baz: 3 }
var dyn bar = 'foo'
var dyn baz

{bar, baz} = foo

console.log(bar, baz)