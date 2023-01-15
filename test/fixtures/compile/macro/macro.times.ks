extern console

macro times_five(e) => 5 * #(e)

console.log(times_five(42))

console.log(times_five(21 * 2))

var dyn i = 42
var dyn t = 2

console.log(times_five(i * t))