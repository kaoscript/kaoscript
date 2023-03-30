extern console

var {foo = 3, bar = 6, qux} = { foo: 2, qux: 9 }

console.log(foo, bar, qux)
// 2 6 9