extern console

var {foo, bar? = null, qux} = { foo: 2, qux: 9 }

console.log(foo, bar, qux)
// 2 null 9