extern console

const foo = { bar: 'hello', baz: 3 }

const {bar, baz} = foo

bar = 'foo'

console.log(bar, baz)