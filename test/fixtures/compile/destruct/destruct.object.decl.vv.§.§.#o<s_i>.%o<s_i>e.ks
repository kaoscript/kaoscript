extern console

var foo = { bar: 'hello', baz: 3 }

var {bar, baz}: {bar: String, baz: Number} = foo

console.log(`\(bar)`, baz + 1)