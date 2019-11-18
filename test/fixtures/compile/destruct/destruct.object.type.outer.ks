extern console

const foo = { bar: 'hello', baz: 3 }

const {bar, baz}: {bar: String, baz: Number} = foo

console.log(`\(bar)`, baz + 1)