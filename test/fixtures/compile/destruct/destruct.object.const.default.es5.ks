#![format(destructuring='es5', variables='es5')]

extern console

const foo = { bar: 'hello', baz: 3 }

const {bar, baz} = foo

console.log(bar, baz)