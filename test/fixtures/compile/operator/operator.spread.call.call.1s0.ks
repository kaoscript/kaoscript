let foo = (() => [1, 2])()
let bar = []

bar.push(0, ...foo)