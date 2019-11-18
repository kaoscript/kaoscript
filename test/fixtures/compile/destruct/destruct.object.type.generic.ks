extern console

const foo = { bar: 1, baz: 3 }

const {bar, baz}: Dictionary<Number> = foo

console.log(bar + baz, baz + 1)