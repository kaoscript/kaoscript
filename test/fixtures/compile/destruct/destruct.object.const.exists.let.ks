extern console

let foo = { bar: 'hello', baz: 3 }
let bar = 'foo'

const {bar, baz} = foo

console.log(bar, baz)