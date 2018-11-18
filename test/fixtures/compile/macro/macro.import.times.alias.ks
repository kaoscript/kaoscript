extern console

import './macro.export.times' for times_five => t5

console.log(t5!(42))

console.log(t5!(21 * 2))

let i = 42
let t = 2

console.log(t5!(i * t))