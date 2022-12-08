extern console

var foo = { bar: 1, baz: 3 }

var {bar, baz}: Object<Number> = foo

console.log(bar + baz, baz + 1)