#![target(ecma-v5)]

extern console

let {foo = 3, bar = 6, qux} = { foo: 2, qux: 9 }

console.log(foo, bar, qux)
// 2 6 9

{foo = 3, bar, qux = 7} = { foo: null }

console.log(foo, bar, qux)
// 3 null 7

{foo = 5} = { bar: 2 }

console.log(foo, bar, qux)
// 5 null 7

{foo, bar, qux} = { foo: 2, qux: 9 }

console.log(foo, bar, qux)
// 2 null 9