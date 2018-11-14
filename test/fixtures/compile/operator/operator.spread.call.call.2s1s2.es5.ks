#![format(functions='es5', parameters='es5', spreads='es5')]

let foo = [1, 2]
let bar = []
let qux = [3, 2]

bar.push(0, 4, ...foo, 1, ...qux, 7, 9)