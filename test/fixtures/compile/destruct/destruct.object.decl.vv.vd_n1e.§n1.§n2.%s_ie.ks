extern console

var dyn foo = { bar: 'hello', baz: 3 }
var dyn bar = 'foo'

var {bar, baz} = foo

console.log(bar, baz)