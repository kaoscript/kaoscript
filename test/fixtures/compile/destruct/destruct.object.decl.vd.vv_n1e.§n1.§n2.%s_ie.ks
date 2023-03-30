extern console

var dyn foo = { bar: 'hello', baz: 3 }
var bar = 'foo'

var dyn {bar, baz} = foo

console.log(bar, baz)