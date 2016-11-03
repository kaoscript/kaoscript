extern console, foo, qux

bar ?= foo?[qux]

console.log(foo, bar)