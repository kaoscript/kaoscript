#![target(ecma-v5)]

extern console

const foo = { bar: 'hello', baz: 3 }
let bar = 'foo'

{bar, baz} = foo

console.log(bar, baz)