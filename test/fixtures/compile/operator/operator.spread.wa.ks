let foo: array = (() => [1, 2])()
let bar = []

bar.push(...foo)