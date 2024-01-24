extern console

import './macro.export.times.default.ks' for times_five => t5

console.log(t5(42))

console.log(t5(21 * 2))

var dyn i = 42
var dyn t = 2

console.log(t5(i * t))