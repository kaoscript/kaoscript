extern console

export macro times_five(e) => 5 * #e

console.log(times_five!(42))

console.log(times_five!(21 * 2))

let i = 42
let t = 2

console.log(times_five!(i * t))