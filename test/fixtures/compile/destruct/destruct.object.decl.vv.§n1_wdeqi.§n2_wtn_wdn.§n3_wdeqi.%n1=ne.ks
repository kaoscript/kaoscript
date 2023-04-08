extern console

var {foo = 3, bar? = null, qux = 7} = { foo: null }

console.log(foo, bar, qux)
// 3 null 7