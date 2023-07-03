extern console, foo, qux

var dyn bar

bar ?= foo?[qux]

console.log(foo, bar)